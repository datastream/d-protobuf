private import io;
private import messagelite;

class Message : MessageLite
{
    byte[] unknown_fields()
    {
        return _unknown_fields;
    }
    byte[] mutable_unknown_fields()
    {
        return _unknown_fields.dup;
    }
    size_t GetCachedSize()
    {
        return cached_size;
    }
    void SetCachedSize(int size)
    {
        cached_size = size; 
    }
    byte[] _unknown_fields;
    bool IsInitialized()
    {
        return true; //Quickly check if all required fields have values set
    }
    void CheckTypeAndMergeFrom(Message other)
    {
    }
    byte* SerializeToBytes(byte* tmp)
    {
        return _unknown_fields.ptr;
    }
    void MergePartialFromStream(ref CodedInputStream input)
    {
      return;
    }
    this()
    {
      super();
    }
}
