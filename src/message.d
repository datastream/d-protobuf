module message;

import descriptor;
import io;

class Message
{
    // Basic Operations ------------------------------------------------
    void CopyFrom(Message from){}
    void MergeFrom(Message from){}
    void Clear(){}
    bool IsInitialized(){}
    void CheckInitialized();
    void FindInitializationErrors(string[] errors){}
    string InitializationErrorString();
    void DiscardUnknownFields(){}

    // Debugging -------------------------------------------------------
    string DebugString();
    // Like DebugString(), but with less whitespace.
    string ShortDebugString();
    // Convenience function useful in GDB.  Prints DebugString() to stdout.
    void PrintDebugString();

    // Parsing ---------------------------------------------------------
    bool ParseFromCodedStream(CodedInputStream input);
    bool ParsePartialFromCodedStream(CodedInputStream input);
    bool ParseFromZeroCopyStream(ZeroCopyInputStream input);
    bool ParsePartialFromZeroCopyStream(ZeroCopyInputStream input);
    bool ParseFromString(string data);
    bool ParsePartialFromString(string data);
    bool ParseFromArray(void[] data,int size);
    bool ParsePartialFromArray(void[] data,int size);
    bool ParseFromFileDescriptor(int file_descriptor);
    bool ParsePartialFromFileDescriptor(int file_descriptor);
    bool ParseFromIstream(istream input);
    bool ParsePartialFromIstream (istream input);
    bool MergeFromCodedStream(CodedInputStream input);
    bool MergePartialFromCodedStream(CodedInputStream input){}
    
    // Serialization ---------------------------------------------------
    bool SerializeToCodedStream(CodedOutputStream output);
    bool SerializePartialToCodedStream(CodedOutputStream output);
    bool SerializeToZeroCopyStream(ZeroCopyOutputStream output);
    bool SerializePartialToZeroCopyStream(ZeroCopyOutputStream output);
    bool SerializeToString(string output);
    bool SerializePartialToString(string output);
    bool SerializeToArray(void[] data,int size);
    bool SerializePartialToArray(void[] data,int size);
    bool SerializeToFileDescriptor(int file_descriptor);
    bool SerializePartialToFileDescriptor(int file_descriptor);
    bool SerializeToOstream(ostream output);
    bool SerializePartialToOstream(ostream output);
    string SerializeAsString();
    string SerializePartialAsString();
    bool AppendToString(string output);
    bool AppendPartialToString(string output);
    int ByteSize(){} 
    int SpaceUsed(){} 
    bool SerializeWithCachedSizes(CodedOutputStream output){return false;}
    int GetCachedSize(){return 0;}
private:
    void SetCachedSize(int size){}
public:
    Descriptor GetDescriptor(){return null;}
    Reflection GetReflection(){return null;}
}
interface Reflection
{
    UnknownFieldSet GetUnknownFieldSet(Message message);
    UnknownFieldSet MutableUnknownFields(Message message);
    int SpaceUsed();
    // Check if the given non-repeated field is set.
    bool HasField(Message message,FieldDescriptor field);
    // Get the number of elements of a repeated field.
    int FieldSize(Message message,FieldDescriptor field);
    void ListFields(Message message,FieldDescriptor[] field);
    int GetInt32(Message message,FieldDescriptor field);
    long GetInt64(Message message,FieldDescriptor field);
    uint GetUInt32(Message message,FieldDescriptor field);
    ulong GetUInt64(Message message,FieldDescriptor field);
    float GetFloat(Message message,FieldDescriptor field);
    double GetDouble(Message message,FieldDescriptor field);
    bool GetBool(Message message,FieldDescriptor field);
    string GetString(Message message,FieldDescriptor field);
    EnumValueDescriptor GetEnumValueDescriptor(Message message,FieldDescriptor field);
    Message GetMessage(Message message,FieldDescriptor field);
    string GetStringReference(Message message,FieldDescriptor field, string scratch);
    void SetInt32(Message message, FieldDescriptor field, int value);
    void SetInt64(Message message, FieldDescriptor field, long value);
    void SetUInt32(Message message, FieldDescriptor field, uint value);
    void SetUInt64(Message message, FieldDescriptor field, ulong value);
    void SetFloat(Message message, FieldDescriptor field, float value);    
    void SetDouble(Message message, FieldDescriptor field, double value);
    void SetBool(Message message, FieldDescriptor field, bool value);
    void SetString(Message message, FieldDescriptor field, string value);
    void SetEnum(Message message, FieldDescriptor field, EnumValueDescriptor value);
    Message MutableMessage(Message message, FieldDescriptor field);
    int GetRepeatedInt32(Message message, FieldDescriptor field, int index);
    long GetRepeatedInt64(Message message, FieldDescriptor field, int index);
    uint GetRepeatedUInt32(Message message, FieldDescriptor field, int index);
    ulong GetRepeatedUInt64(Message message, FieldDescriptor field, int index);
    float GetRepeatedFloat(Message message, FieldDescriptor field, int index);
    double GetRepeatedDouble(Message message, FieldDescriptor field, int index);
    bool GetRepeatedBool(Message message, FieldDescriptor field, int index);
    string GetRepeatedString(Message message, FieldDescriptor field, int index);
    EnumValueDescriptor GetRepeatedEnum(Message message, FieldDescriptor field, int index);
    string GetStringReference(Message message, FieldDescriptor field, int index, string scratch);
    void SetRepeatedInt32(Message message, FieldDescriptor field, int index, int value);
    void SetRepeatedInt64(Message message, FieldDescriptor field, int index, long value);
    void SetRepeatedUInt32(Message message, FieldDescriptor field, int index, uint value);
    void SetRepeatedUInt64(Message message, FieldDescriptor field, int index, ulong value);
    void SetRepeatedFloat(Message message, FieldDescriptor field, int index, float value);
    void SetRepeatedDouble(Message message, FieldDescriptor field, int index, double value);
    void SetRepeatedBool(Message message, FieldDescriptor field, int index, bool value);
    void SetRepeatedString(Message message, FieldDescriptor field, int index, string value);
    void SetRepeatedEnum(Message message, FieldDescriptor field, int index, EnumValueDescriptor value);
    Message MutableRepeatedMessage(Message message, FieldDescriptor field, int index);
    void AddInt32(Message message, FieldDescriptor field, int value);
    void AddInt64(Message message, FieldDescriptor field, long value);
    void AddUInt32(Message message, FieldDescriptor field, uint value);
    void AddUInt64(Message message, FieldDescriptor field, ulong value);
    void AddFloat(Message message, FieldDescriptor field, float value);
    void AddDouble(Message message, FieldDescriptor field, double value);
    void AddBool(Message message, FieldDescriptor field, bool value);
    void AddString(Message message, FieldDescriptor field, string value);
    void AddEnum(Message message, FieldDescriptor field, EnumValueDescriptor value);
    Message AddMessage(Message message, FieldDescriptor field);
    FieldDescriptor FindKnownExtensionByName(string name);
    FieldDescriptor FindKnownExtensionByNumber(int number);
}
class MessageFactory
{
    static Message GetPrototype(Descriptor type){return null;}
    static MessageFactory generated_factory()
    {
    }
    static void InternalRegisterGeneratedMessage(Descriptor descriptor, MessageFactory prototype)
    {
    }
}
