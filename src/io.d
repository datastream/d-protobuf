module io;

private import commen;
private import tango.io.device.File;
private import tango.net.device.Socket;
private import tango.stdc.string;
private alias char[] string;
import tango.io.Stdout;

class ZeroCopyInputStream
{
  File zfd;
  Socket zsd;
  byte* buffer;
  size_t buffer_length;
  size_t delegate(ref byte[] buffer, size_t size) callbackread;
  enum StreamType {
    FILE    = 1,
    SOCKET  = 2,
    BUFFER  = 3,
  }
  StreamType mode;
  this(File fd)
  {
    /* raw_stream = cast(byte[])fd.load; */
    zfd = fd;
    callbackread = &ReadCache;
    mode = StreamType.FILE;
  }
  this(Socket fd)
  {
    /* raw_stream = cast(byte[])fd.load; */
    zsd = fd;
    callbackread = &ReadCache;
    mode = StreamType.SOCKET;
  }
  this(byte[] buffer)
  {
    this.buffer = buffer.ptr;
    this.buffer_length = buffer.length;
    mode = StreamType.BUFFER;
  }
  size_t ReadCache(ref byte[] buffer, size_t size)
  {
    byte[]  dst;
    size_t  i, len, chunk;
    if(mode == StreamType.FILE) {
      if (size != -1) {
        chunk = size;
      } else {
        chunk = zfd.conduit.bufferSize;
      }
      while (len < size)
      {
        int rst = zfd.length - zfd.position;
        if (dst.length - len is 0) {
          dst.length = len + chunk;
        }
        if (( i = zfd.read (dst[len .. $])) is zfd.Eof){
          len += rst;
          break;
        }
        len += i;
      }
    } else if(mode == StreamType.SOCKET) {
      if (size != -1) {
        chunk = size;
      } else {
        chunk = zsd.conduit.bufferSize;
      }
      
      while (len < size)
      {
        if (dst.length - len is 0)
          dst.length = len + chunk;
        
        if (( i = zsd.read (dst[len .. $])) is zsd.Eof){
          len += i;
          break;
        }
        len += i;
      }      
    }
    buffer ~= dst[0..len];
    // raw_stream.seek(off_size);
    // buffer = (zfd.load(size)).ptr;
    return len;
  }
}
class CodedInputStream
{
  this(ZeroCopyInputStream* coded_input)
  {
    this.coded_raw = coded_input;
    TotalBytes = 0;
    buffer_end = coded_stream.ptr + TotalBytes;
    SetCache();
    if(coded_raw.mode == coded_raw.StreamType.BUFFER) {
      input = coded_raw.buffer;
      buffer_end = input + coded_raw.buffer_length;
    } else {
      Refresh();
      input = coded_stream.ptr;
    }
  }
  this()
  {
    SetCache();
  }
  void SetCache(size_t size = 1024)
  {
    cache_size = size;
  }
  bool Skip(size_t size)
  {
    if(size < BufferSize()) {
      input += size;
    } else {
      if(Refresh()) {
        input += size;
      } else {
        return false;
      }
    }
    return true;
  }
  bool Refresh()
  {
    if(coded_raw.mode == coded_raw.StreamType.BUFFER)
      return false;
    int buffer_size = coded_raw.callbackread(coded_stream, cache_size);
    if(buffer_size != 0) {
      TotalBytes += buffer_size;
      buffer_end = coded_stream.ptr + TotalBytes;
      if(TotalBytes > DefaultTotalBytesWarningThreshold) {
        if(TotalBytes > DefaultTotalBytesLimit) {
          throw new Exception("Reatch Recursion limit.");
        } else {
          throw new Exception("Reatch warning limit.");
        }
      }
      return true;
    } else {
      return false;
    }
  }
  bool GetDirectBufferPointer(ref byte* buffer, ref int size)
  {
    if(BufferSize() == 0 && Refresh()) return false;
    buffer = input;
    size = BufferSize();
    return true;
  }
  byte* GetCurBufferPointer()
  {
    return input;
  }
  bool ReadRaw(ref byte[] buffer, int size)
  {
    if(BufferSize() < size) {
      if(!Refresh()) return false;
    }
    if(BufferSize() >= size) {
      memcpy(buffer.ptr, input, size);
      input += size;
    }
    return true;
  }
  bool ReadString(ref char[] buffer, int size)
  {
    if(BufferSize() < size) {
      if(!Refresh()) return false;
    }
    memcpy(&buffer, input, size);
    input += size;
    return true;
  }
  bool ReadLittleEndian32(ref uint value)
  {
    byte[] bytes;
    bytes.length = value.sizeof;
    if(BufferSize() >= value.sizeof) {
      memcpy(bytes.ptr, input, value.sizeof);
      input += value.sizeof;
    } else {
      if (!ReadRaw(bytes, value.sizeof))
        return false;
    }
    ReadLittleEndian32FromBytes(bytes.ptr, value);
    return true;
  }
  bool ReadLittleEndian64(ref ulong value)
  {
    byte[] bytes;
    bytes.length = value.sizeof;
    if(BufferSize() >= value.sizeof) {
      memcpy(bytes.ptr, input, value.sizeof);
      input += value.sizeof;
    } else {
      if (!ReadRaw(bytes, value.sizeof))
        return false;
    }
    ReadLittleEndian64FromBytes(bytes.ptr, value);
    return true;
  }
  bool ReadVarint32(ref uint value)
  {
    return ReadVarint!(uint)(value);
  }
  bool ReadVarint64(ref ulong value)
  {
    return ReadVarint!(ulong)(value);
  }
  bool ReadVarint(T)(ref T value)
  {
    uint i;
    bool mutilbuffer = false;
    uint bits = MaxVarintBytes;
    if(uint.sizeof == T.sizeof)
      bits = MaxVarint32Bytes;
    void readvarint()
    {
      while(BufferSize() > 0)
      {
        byte b;
        b = *input;
        if(i <= bits) {
          value |= (cast(T)(b & 0x7f)) << (7*i);
        } else {
          throw new Exception("Data corrupt");
        }
        i++;
        input++;
        if((b & 0x80) == 0) {
          mutilbuffer = false;
          return;
        }
      }
      if(coded_raw.mode != coded_raw.StreamType.BUFFER)
        mutilbuffer = true;
    }
    readvarint();
    if(mutilbuffer) {
      if(Refresh()) {
        readvarint();
      }
    }
    return true;
  }
  uint ReadTag()
  {
    last_tag = 0;
    if(ReadVarint32(last_tag))
      return last_tag;
    return 0;
  }
  bool ExpectTag(uint expected)
  {
    if (expected < (1 << 7)) {
      if((BufferSize() > 0) &&(*(input) == expected)) {
        input ++;
        return true;
      } else {
        return false;
      }
    } else if (expected < (1 << 14)) {
      if ((BufferSize() >= 2) &&
          *input == cast(byte)(expected | 0x80) &&
          *(input + 1) == cast(byte)(expected >> 7)) {
        input += 2;
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
  /*
   * Read from buffer functions
   */
  byte* ReadLittleEndian32FromBytes(byte* buffer, ref uint value)
  {
    version(LittleEndian) {
      memcpy(&value, buffer, value.sizeof);
    }
    version(BigEndian) {
      value = cast(uint)(buffer[0]      ) |
              cast(uint)(buffer[1] >>  8) |
              cast(uint)(buffer[2] >> 16) |
              cast(uint)(buffer[3] >> 24);
    }
    return buffer + value.sizeof;
  }
  byte* ReadLittleEndian64FromBytes(byte* buffer, ref ulong value)
  {
    version(LittleEndian) {
      memcpy(&value, buffer, value.sizeof);
    }
    version(BigEndian) {
      uint part0 = cast(uint)(buffer[0]      ) |
                   cast(uint)(buffer[1] >>  8) |
                   cast(uint)(buffer[2] >> 16) |
                   cast(uint)(buffer[3] >> 24);
      uint part1 = cast(uint)(buffer[4]      ) |
                   cast(uint)(buffer[5] >>  8) |
                   cast(uint)(buffer[6] >> 16) |
                   cast(uint)(buffer[7] >> 24);
      value = cast(ulong)part0 | (cast(ulong)part2 <<32);
    }
    return buffer + value.sizeof;
  }
  byte* ReadVarint32FromBytes(byte* buffer, ref uint value)
  {
    return ReadVarintFromBytes!(uint)(buffer, value);
  }
  byte* ReadVarint64FromBytes(byte* buffer, ref ulong value)
  {
    return ReadVarintFromBytes!(ulong)(buffer, value);
  }
  byte* ReadVarintFromBytes(T)(byte* buffer, ref T value)
  {
    uint i = 0;
    uint bits = MaxVarintBytes;
    if(uint.sizeof == T.sizeof)
      bits = MaxVarint32Bytes;
    while(!(buffer is null))
    {
      if(i < bits) {
        value |= (cast(T)(*buffer & 0x7F)) << (7*i);
      }
      i++;
      if(!(*buffer & 0x80)) {
        if(i > MaxVarintBytes)
          throw new Exception("Data corrupt");
        return buffer + 1;
      }
      buffer ++;
    }
    return buffer;
  }
  byte* ExpectTagFromBytes(byte* buffer, uint expected)
  {
    if (expected < (1 << 7)) {
      if (buffer[0] == expected) {
        return buffer + 1;
      }
    } else if (expected < (1 << 14)) {
      if (buffer[0] == cast(byte)(expected | 0x80) &&
          buffer[1] == cast(byte)(expected >> 7)) {
        return buffer + 2;
      }
    }
    return null;
  }
  bool LastTagWas(uint expected)
  {
    return last_tag == expected;
  }
  int BytesUntilLimit()
  {
    return 0;
  }
  void SetTotalBytesLimit(int total_bytes_limit, int warning_threshold)
  {
  }
  int BufferSize()
  {
    return buffer_end - input;
  }
  byte[] CodedByte()
  {
    return coded_stream;
  }
 private:
  ZeroCopyInputStream* coded_raw;
  byte* input;
  byte[] coded_stream;
  byte* buffer_end;
  size_t cache_size;
  size_t TotalBytes;
  uint last_tag;
  static const int MaxVarintBytes = 10;
  static const int MaxVarint32Bytes = 5;
  static int DefaultTotalBytesLimit = 64 << 20;
  static const int DefaultTotalBytesWarningThreshold = 32 << 20;
  static const int DefaultRecursionLimit = 64;
}
class ZeroCopyOutputStream
{
  union{
    File zfd;
    Socket zsd;
  }
  CodedOutputStream copyout;
  bool type;
  this(File fd)
  {
    zfd = fd;
    type = true;
  }
  this(Socket fd)
  {
    zsd = fd;
    type = false;
  }
  ~this()
  {
    if(copyout.ByteCount() >0) {
      if (type)
      {
        zfd.write(copyout.coded_stream[0..copyout.ByteCount()]);
      } else {
        zsd.write(copyout.coded_stream[0..copyout.ByteCount()]);
      }
    }
  }
}
class CodedOutputStream
{
  this()
  {
  }
  this(ZeroCopyOutputStream* coded_output)
  {
    zstream = coded_output;
    zstream.copyout = this;
    if(!AppendMore()) {
      throw new Exception("Can't malloc memory");
    }
  }
  bool AppendMore()
  {
    try{
      coded_stream ~= new byte[block_size];
      output = coded_stream.ptr;
      buffer_end = coded_stream.ptr + coded_stream.length;
    }
    catch(Exception e ) {
      return false;
    }
    return true;
  }
  uint BufferSize()
  {
    return buffer_end - output;
  }
  /*
   * Write functions for write data to ZeroCopyOutputStream
   */
  void WriteVarint32(uint value)
  {
    if(BufferSize() >= MaxVarint32Bytes) {
      WriteVarint32Fast(value);
    } else {
      WriteVarint!(uint)(value);
    }
  }
  void WriteVarint64(ulong value)
  {
    if(BufferSize() >= MaxVarintBytes) {
      WriteVarint64Fast(value);
    } else {
      WriteVarint!(ulong)(value);
    }
  }
  void WriteVarint(T)(T value)
  {
    byte[] bytes;
    while (value > 0x7f) {
      bytes ~= (value & 0x7f) | 0x80;
      value >>= 7;
    }
    bytes ~= value & 0x7f;
    WriteRaw(bytes);
  }
  void WriteLittleEndian32(uint value)
  {
    byte[value.sizeof] bytes;
    byte* ptr;
    bool stat = BufferSize() >= value.sizeof;
    if(stat) {
      ptr = output;
      output += 4;
    } else {
      ptr = bytes.ptr;
    }
    WriteLittleEndian32ToBytes(value, ptr);
    if(!stat){
      WriteRaw(bytes);
    }
  }
  void WriteLittleEndian64(ulong value)
  {
    byte[value.sizeof] bytes;
    byte* ptr;
    bool stat = BufferSize() >= value.sizeof;
    if(stat) {
      ptr = output;
      output +=8;
    } else {
      ptr = bytes.ptr;
    }
    WriteLittleEndian64ToBytes(value, ptr);
    if(!stat){
      WriteRaw(bytes);
    }    
  }
  void WriteString(string str)
  {
    WriteRaw(cast(byte[])str);
  }
  void WriteRaw(byte[] buffer)
  {
    if(BufferSize() < buffer.length) {
      AppendMore();
    }
    memcpy(output,&buffer,buffer.sizeof);
    output += buffer.length;
  }
  void WriteVarint32Fast(uint value)
  {
    byte* target = output;
    target[0] = value | 0x80;
    if (value >= (1 << 7)) {
      target[1] = (value >>  7) | 0x80;
      if (value >= (1 << 14)) {
        target[2] = (value >> 14) | 0x80;
        if (value >= (1 << 21)) {
          target[3] = (value >> 21) | 0x80;
          if (value >= (1 << 28)) {
            target[4] = value >> 28;
            output += 5;
            return ;
          } else {
            target[3] &= 0x7f;
            output += 4;
            return ;
          }
        } else {
          target[2] &= 0x7f;
          output += 3;
          return ;
        }
      } else {
        target[1] &= 0x7f;
        output += 2;
        return ;
      }
    } else {
      target[0] &= 0x7f;
      output += 1;
      return ;
    }
  }
  void WriteVarint64Fast(ulong value)
  {
    uint part0 = cast(uint)(value      );
    uint part1 = cast(uint)(value >> 28);
    uint part2 = cast(uint)(value >> 56);
    int size;
    if (part2 == 0) {
      if (part1 == 0) {
        if (part0 < (1 << 14)) {
          if (part0 < (1 << 7)) {
            size = 1; goto size1;
          } else {
            size = 2; goto size2;
          }
        } else {
          if (part0 < (1 << 21)) {
            size = 3; goto size3;
          } else {
            size = 4; goto size4;
          }
        }
      } else {
        if (part1 < (1 << 14)) {
          if (part1 < (1 << 7)) {
            size = 5; goto size5;
          } else {
            size = 6; goto size6;
          }
        } else {
          if (part1 < (1 << 21)) {
            size = 7; goto size7;
          } else {
            size = 8; goto size8;
          }
        }
      }
    } else {
      if (part2 < (1 << 7)) {
        size = 9; goto size9;
      } else {
        size = 10; goto size10;
      }
    }
 size10: output[9] = cast(byte)((part2 >>  7) | 0x80);
 size9 : output[8] = cast(byte)((part2      ) | 0x80);
 size8 : output[7] = cast(byte)((part1 >> 21) | 0x80);
 size7 : output[6] = cast(byte)((part1 >> 14) | 0x80);
 size6 : output[5] = cast(byte)((part1 >>  7) | 0x80);
 size5 : output[4] = cast(byte)((part1      ) | 0x80);
 size4 : output[3] = cast(byte)((part0 >> 21) | 0x80);
 size3 : output[2] = cast(byte)((part0 >> 14) | 0x80);
 size2 : output[1] = cast(byte)((part0 >>  7) | 0x80);
 size1 : output[0] = cast(byte)((part0      ) | 0x80);

    output[size-1] &= 0x7f;
    output += size;
  }
  void WriteTag(uint value)
  {
    WriteVarint32(value);
  }
  void WriteVarint32SignExtended(int value)
  {
    if(value < 0) {
      WriteVarint64(value);
    } else {
      WriteVarint32(value);
    }
  }
  /*
   * function for write data to bytes
   */
  byte* WriteTagToBytes(uint value, byte* target)
  {
    return WriteVarint32ToBytes(value, target);
  }
  byte* WriteVarint32SignExtendedToBytes(int value, byte* target)
  {
    if(value < 0) {
      return WriteVarint64ToBytes(value, target);
    } else {
      return WriteVarint32ToBytes(value, target);
    }
  }
  byte* WriteVarint32ToBytes(int value, byte* target)
  {
    target[0] = value | 0x80;
    if (value >= (1 << 7)) {
      target[1] = (value >>  7) | 0x80;
      if (value >= (1 << 14)) {
        target[2] = (value >> 14) | 0x80;
        if (value >= (1 << 21)) {
          target[3] = (value >> 21) | 0x80;
          if (value >= (1 << 28)) {
            target[4] = value >> 28;
            target += 5;
            return target;
          } else {
            target[3] &= 0x7f;
            target += 4;
            return target;
          }
        } else {
          target[2] &= 0x7f;
          target += 3;
          return target;
        }
      } else {
        target[1] &= 0x7f;
        target += 2;
        return target;
      }
    } else {
      target[0] &= 0x7f;
      target += 1;
      return target;
    }
  }
  byte* WriteVarint64ToBytes(long value, byte* target)
  {
    uint part0 = cast(uint)(value      );
    uint part1 = cast(uint)(value >> 28);
    uint part2 = cast(uint)(value >> 56);
    int size;
    if (part2 == 0) {
      if (part1 == 0) {
        if (part0 < (1 << 14)) {
          if (part0 < (1 << 7)) {
            size = 1; goto size1;
          } else {
            size = 2; goto size2;
          }
        } else {
          if (part0 < (1 << 21)) {
            size = 3; goto size3;
          } else {
            size = 4; goto size4;
          }
        }
      } else {
        if (part1 < (1 << 14)) {
          if (part1 < (1 << 7)) {
            size = 5; goto size5;
          } else {
            size = 6; goto size6;
          }
        } else {
          if (part1 < (1 << 21)) {
            size = 7; goto size7;
          } else {
            size = 8; goto size8;
          }
        }
      }
    } else {
      if (part2 < (1 << 7)) {
        size = 9; goto size9;
      } else {
        size = 10; goto size10;
      }
    }
 size10: target[9] = cast(byte)((part2 >>  7) | 0x80);
 size9 : target[8] = cast(byte)((part2      ) | 0x80);
 size8 : target[7] = cast(byte)((part1 >> 21) | 0x80);
 size7 : target[6] = cast(byte)((part1 >> 14) | 0x80);
 size6 : target[5] = cast(byte)((part1 >>  7) | 0x80);
 size5 : target[4] = cast(byte)((part1      ) | 0x80);
 size4 : target[3] = cast(byte)((part0 >> 21) | 0x80);
 size3 : target[2] = cast(byte)((part0 >> 14) | 0x80);
 size2 : target[1] = cast(byte)((part0 >>  7) | 0x80);
 size1 : target[0] = cast(byte)((part0      ) | 0x80);

    target[size - 1] &= 0x7f;
    target += size;
    return target;
  }
  byte* WriteLittleEndian32ToBytes(uint value, byte* target)
  {
    version(LittleEndian) {
      memcpy(target, &value, value.sizeof);
    }
    version(BigEndian) {
      target[0] = cast(byte)(value      );
      target[1] = cast(byte)(value >>  8);
      target[2] = cast(byte)(value >> 16);
      target[3] = cast(byte)(value >> 24);
    }
    return target + 4;
  }
  byte* WriteLittleEndian64ToBytes(ulong value, byte* target)
  {
    version(LittleEndian) {
      memcpy(target, &value, value.sizeof);
    }
    version(BigEndian) {
      uint part0 = cast(uint)(value);
      uint part1 = cast(uint)(value >> 32);
      target[0] = cast(byte)(part0      );
      target[1] = cast(byte)(part0 >>  8);
      target[2] = cast(byte)(part0 >> 16);
      target[3] = cast(byte)(part0 >> 24);
      target[4] = cast(byte)(part1      );
      target[5] = cast(byte)(part1 >>  8);
      target[6] = cast(byte)(part1 >> 16);
      target[7] = cast(byte)(part1 >> 24);
    }
    return target + 9;
  }
  byte* WriteStringToBytes(char[] value, byte* target)
  {
    memcpy(target, &value, value.length);
    return target + value.length;
  }
  uint ByteCount()
  {
    return output - coded_stream.ptr;
  }
 private:
  byte[] coded_stream;
  byte* output;  //cur_opt
  byte* buffer_end;
  ZeroCopyOutputStream* zstream;
  static const int MaxVarintBytes = 10;
  static const int MaxVarint32Bytes = 5;
  static const int block_size = 4096;
  size_t total_size;
  bool had_error;
}
/*
 * function for bytes size
 */
uint VarintSize32(uint value)
{
  if (value < (1 << 7)) {
    return 1;
  } else if (value < (1 << 14)) {
    return 2;
  } else if (value < (1 << 21)) {
    return 3;
  } else if (value < (1 << 28)) {
    return 4;
  } else {
    return 5;
  }
}
uint VarintSize64(ulong value)
{
  if (value < (cast(ulong)1 << 35)) {
    if (value < (cast(ulong)1 << 7)) {
      return 1;
    } else if (value < (cast(ulong)1 << 14)) {
      return 2;
    } else if (value < (cast(ulong)1 << 21)) {
      return 3;
    } else if (value < (cast(ulong)1 << 28)) {
      return 4;
    } else {
      return 5;
    }
  } else {
    if (value < (1L << 42)) {
      return 6;
    } else if (value < (cast(ulong)1 << 49)) {
      return 7;
    } else if (value < (cast(ulong)1 << 56)) {
      return 8;
    } else if (value < (cast(ulong)1 << 63)) {
      return 9;
    } else {
      return 10;
    }
  }
}
uint VarintSize32SignExtended(int value)
{
  if(value < 0) {
    return VarintSize64(cast(ulong)value);
  }
  else {
    return VarintSize32(cast(uint)value);
  }
}

debug(UnitTest)
{
  unittest
  {
    CodedOutputStream output = new CodedOutputStream;
    //assert(output.WriteVarint32(1));
  }
}
