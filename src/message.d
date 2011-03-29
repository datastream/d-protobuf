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
        _cached_size_ = size; 
    }
    byte[] _unknown_fields;
    bool IsInitialized()
    {
        return true; //Quickly check if all required fields have values set
    }
    void CheckTypeAndMergeFrom(Message other)
    {
        if(other.classinfo.name is this.classinfo.name)
        {
          this.PartialSerialize()~other.PartialSerialize();
        }
    }
    byte[] Serialize()
    {
        return _unknown_fields;
    }
    Message Deserialize(byte[] input)
    {
        return new Message(input);
    }
}
