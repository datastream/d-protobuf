module codegen;

private import tango.io.device.File;
private import tango.text.Util;
private import tango.util.log.Log;
private import tango.util.log.Config;
import descriptor;
import writer;
import prototype;
private import commen;

private alias char[] string;

class CodeGen
{
  string[char[]] code;
  string package_name;
  string class_init;
  FileDescriptor messages;
  this(FileDescriptor fd)
  {
    auto logger = Log.lookup("protobuf");
    for(int i =0; i< fd.dependency_count(); i++)
    {
      CodeGen a = new CodeGen(fd.dependency(i));
    }
    this.messages = fd;
    try 
    {
      Format tr = new Format(fd.name());
      tr.FormatWriteToFile(genCode());
    }
    catch(Exception x)
    {
      logger.error ("Exception: formater " ~ x.toString);
    }
    has_ext = false;
  }
  string genCode()
  {
    string rst;
    //rst ~= "package " ~this.messages.package_name()~";";
    rst ~="import message;import io;import prototype;";
    for(int i = 0; i < this.messages.message_count();i++)
    {
      rst ~= genMessageCode(this.messages.message(i));
    }
    for(int i= 0; i < this.messages.extension_count(); i++)
    {
      rst ~= genFieldCode(this.messages.extension(i));
    }
    if(has_ext)
      rst ~= "import extension;";
    return rst;
  }
  string genMessageCode(Descriptor msg)
  {
    string rst;
    if(msg.containing_type())
      rst ~= "static ";
    rst ~= "class "~msg.name() ~" : Message {";
    int n = 0;
    for(int i =0; i< msg.field_count(); i++)
    {
      if(!msg.field(i).is_repeated())
        n++;
      rst ~= genFieldCode(msg.field(i));
    }
    for(int i =0; i< msg.extension_count(); i++)
    {
      rst ~= genFieldCode(msg.extension(i));
    }
    rst ~= "uint[("~ tango.text.convert.Integer.toString(n) ~" + 31) / 32] _has_bits_;size_t cached_size;";
    rst ~= "bool has_bit(int index){return (_has_bits_[index / 32] & (1u << (index % 32))) != 0;}void set_bit(int index){_has_bits_[index / 32] |= (1u << (index % 32));}void clear_bit(int index){_has_bits_[index / 32] &= ~(1u << (index % 32));}void SetCachedSize(int size){cached_size = size;}";
    //rst ~= "static " ~ msg.full_name() ~ "* default_instance_;";
    n = 0;
    for(int i =0; i< msg.field_count(); i++)
    {
      if(!msg.field(i).is_repeated())
        n++;
      rst ~= genFuncCode(msg.field(i),n);
    }
    for(int i =0;i < msg.enum_type_count();i++)
    {
      rst ~= genEnum(msg.enum_type(i));
    }
    if(msg.extension_range_count()>0)
    {
      has_ext = true;
      rst ~="void SerializeExtension(ref CodedOutputStream output){ExtensionIdentifier*[] elements = extensionset.IsClass(this);for(int i = 0; i < elements.length; i++){elements[i].Serialize(output);}}void ExtensionMergePartialFromStream(ref CodedInputStream input){ExtensionIdentifier*[] elements = extensionset.IsClass(this);for(int i = 0; i < elements.length; i++){elements[i].MergePartialFromStream(input);}}";
      rst ~= getExtensionFunc(msg);
    }
    rst ~= genCodeFunc(msg);
    for(int i =0; i< msg.nested_type_count(); i++)
    {
      rst ~= genMessageCode(msg.nested_type(i));
    }
    rst ~= "this(){super();" ~ class_init ~ "}}";
    class_init = "";
    return rst;
  }
  string genFieldCode(FieldDescriptor field)
  {
    string rst;
    if(field.is_extension())
    {
      string rtype;
      rtype = GetDTypeToString(field.type());
      if(rtype is null)
        rtype = field.msg_enum;
      if(field.type() == FieldType.TYPE_ENUM)
      {
        rtype = "int";
      }
      rst ~= "ExtensionIdentifier " ~ field.name() ~";";
      class_init ~= field.name() ~ " = new ExtensionIdentifier(\"" ~ field.containing_type().name() ~ "\", " ~ (field.is_repeated()? "true":"false")~ "," ~  (field.is_packed()?"true":"false") ~ "," ~ FieldTypeToString(field.type()) ~ ","~ tango.text.convert.Integer.toString(field.number()) ~ (field.has_default_value()?","~ field.getdefultvalue():"") ~");";
      return rst;
    }
    string rtype;
    rtype = GetDTypeToString(field.type());
    if(rtype is null)
      rtype = field.msg_enum;
    if(field.type() == FieldType.TYPE_ENUM)
    {
      rtype ="int";
    }
    rst ~= rtype ~(field.is_repeated()? "[]":" ") ~ " " ~ field.name() ~(field.has_default_value()?"_="~field.getdefultvalue()~";" :"_;");
    return rst;
  }
  string genFuncCode(FieldDescriptor field, int i)
  {
    string rst;
    switch(field.type())
    {
      case FieldType.TYPE_BYTES:
      case FieldType.TYPE_STRING:
        {
          rst ~= genString(field,i);
          break;
        }
      case FieldType.TYPE_INT32:
      case FieldType.TYPE_INT64:
      case FieldType.TYPE_UINT32:
      case FieldType.TYPE_UINT64:
      case FieldType.TYPE_SINT32:
      case FieldType.TYPE_SINT64:
      case FieldType.TYPE_FIXED32:
      case FieldType.TYPE_FIXED64:
      case FieldType.TYPE_SFIXED32:
      case FieldType.TYPE_SFIXED64:
      case FieldType.TYPE_DOUBLE:
      case FieldType.TYPE_FLOAT:
      case FieldType.TYPE_BOOL:
      case FieldType.TYPE_ENUM:
        {
          rst ~= genDigital(field,i);
          break;
        }
      case FieldType.TYPE_MESSAGE:
        {
          rst ~= genObject(field,i);
          break;
        }
      default:
        break;
    }
    return rst;
  }
  string genDigital(FieldDescriptor field, int i)
  {
    string rst;
    string rtype;
    rtype = GetDTypeToString(field.type());
    if(rtype is null)
      rtype = field.msg_enum();
    if(field.type() == FieldType.TYPE_ENUM)
      rst ~= rtype ~ (field.is_repeated()?"[] ":" ") ~field.name() ~ "(){return cast("~ field.default_value_enum().type().name() ~")" ~field.name() ~ "_;}";
    else
        rst ~= rtype ~ (field.is_repeated()?"[] ":" ") ~field.name() ~ "(){return "~ field.name() ~ "_;}";
    if(!field.is_repeated())
    {
      rst ~= "bool has_" ~ field.name() ~ "(){return has_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");}";
      if(field.has_default_value())
      {
        if(field.type() == FieldType.TYPE_ENUM)
          rst ~= "void clear_" ~ field.name() ~ "(){" ~ field.name() ~ "_ =" ~ field.getdefultvalue() ~ ";clear_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");}";
        else
            rst ~= "void clear_" ~ field.name() ~ "(){" ~ field.name() ~ "_ =" ~ field.getdefultvalue() ~ ";clear_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");}";
      }
      else
          rst ~= "void clear_" ~ field.name() ~ "(){clear_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");}";
      rst ~= "void set_" ~ field.name() ~ "("~rtype ~" value){set_bit(" ~ tango.text.convert.Integer.toString(i)~");" ~ field.name() ~ "_ =value;}";
    }
    else
    {
      rst ~= "int "~ field.name() ~ "_size(){return "~ field.name() ~ "_.length;}";
      rst ~= "void clear_" ~ field.name() ~ "(){"~ field.name() ~"_.length = 0;}";
      rst ~= rtype ~ "[] mutable_" ~ field.name() ~ "(){return "~ field.name() ~ "_.dup;}";
      rst ~= rtype ~ " " ~ field.name() ~ "(int index){return "~ field.name() ~ "_[index];}";
      rst ~= "void set_" ~ field.name() ~ "(int index,"~ rtype ~" value){" ~ field.name() ~ "_[index]=value;}";
      rst ~= "void add_" ~ field.name() ~ "("~ rtype ~" value){" ~ field.name() ~ "_ ~=value;}";
      rst ~= "size_t " ~ field.name() ~ "_cached_size;";
    }
    return rst;
  }
  string genObject(FieldDescriptor field,int i)
  {
    string rst;
    string rtype;
    rtype = GetDTypeToString(field.type());
    if(rtype is null)
      rtype = field.msg_enum();
    if(field.type() == FieldType.TYPE_ENUM)
    {
      if(field.FindEnumType().containing_type() != field.containing_type())
        rtype =  substitute(field.FindEnumType().full_name(),"_",".");
    }
    if(!field.is_repeated())
    {
      rst ~= "bool has_" ~ field.name() ~ "(){return has_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");}";
      rst ~= "void clear_" ~ field.name() ~ "(){"~ field.name() ~"_=null;clear_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");}";
      rst ~= rtype ~ " " ~ field.name() ~ "(){return "~ field.name() ~ "_;}";
      rst ~= rtype ~ " mutable_" ~ field.name() ~ "(){set_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");if("~ field.name() ~"_ is null )" ~ field.name() ~ "_ =new "~ rtype ~ ";return "~ field.name() ~ "_;}";
      rst ~= "void set_" ~ field.name() ~ "("~ rtype ~" value){set_bit(" ~ tango.text.convert.Integer.toString(i)~");" ~ field.name() ~ "_=value;}";
    }
    else
    {
      rst ~= "int "~ field.name() ~ "_size(){return "~ field.name() ~ "_.length;}";
      rst ~= "void clear_" ~ field.name() ~ "(){"~ field.name() ~"_.length = 0;}";
      rst ~= rtype ~ "[] "~ field.name() ~ "(){return "~ field.name() ~ "_;}";
      rst ~= rtype ~ "[] mutable_" ~ field.name() ~ "(){return "~ field.name() ~ "_.dup;}";
      rst ~= "void set_" ~ field.name() ~ "(int index,"~ rtype ~" value){" ~ field.name() ~ "_[index]=value;}";
      rst ~= "void add_" ~ field.name() ~ "("~ rtype ~" value){" ~ field.name() ~ "_ ~=value;}"; 
      rst ~= "size_t " ~ field.name() ~ "_cached_size;";
    }
    return rst;
  }
  string genString(FieldDescriptor field, int i)
  {
    string rst;
    string rtype;
    rtype = GetDTypeToString(field.type());
    if(rtype is null)
      rtype = field.msg_enum();
    if(field.type() == FieldType.TYPE_ENUM)
    {
      if(field.FindEnumType().containing_type() != field.containing_type())
        rtype =  field.FindEnumType().name();
    }
    if(!field.is_repeated())
    {
      rst ~= "bool has_" ~ field.name() ~ "(){return has_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");}";
      if(field.has_default_value())
        rst ~= "void clear_" ~ field.name() ~ "(){" ~ field.name() ~ "_ =" ~ field.getdefultvalue() ~ ";clear_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");}";
      else
          rst ~= "void clear_" ~ field.name() ~ "(){" ~ field.name() ~ "_.length = 0;clear_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");}";
      rst ~= rtype ~" "~ field.name() ~ "(){return " ~ field.name() ~"_;}";
      rst ~= "void set_" ~ field.name() ~ "(" ~ rtype ~ " value){set_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");" ~ field.name() ~ "_ =value;}";
      if(field.type() == FieldType.TYPE_BYTES)
      {
        rst ~= "void set_" ~ field.name() ~ "(" ~ rtype ~ " value,size_t size){set_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");" ~ field.name() ~ "_ =value[0 .. size];}";
        rst ~= rtype ~" mutable_"~ field.name() ~ "(){set_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");"~ "return " ~ field.name() ~ "_.dup;}";
      }
    }
    else
    {
      rst ~= "int "~ field.name() ~ "_size(){return "~ field.name() ~ "_.length;}";
      rst ~= "void clear_" ~ field.name() ~ "(){"~ field.name() ~"_.length = 0;}";
      rst ~= rtype ~ "[] "~ field.name() ~ "(){return "~ field.name() ~ "_;}";
      rst ~= rtype ~ "[] mutable"~ field.name() ~ "(){return "~ field.name() ~ "_.dup;}";
      rst ~= rtype ~ " "~ field.name() ~ "(int index){return "~ field.name() ~ "_[index];}";
      if(field.type() == FieldType.TYPE_BYTES)
      {
        rst ~= rtype ~ " mutable"~ field.name() ~ "(int index){return "~ field.name() ~ "_[index].dup;}";
        rst ~= "void set_" ~ field.name() ~ "(int index,"~rtype~" value,size_t size){" ~ field.name() ~"_[index]=value[0 .. size];}";
        rst ~= "void add_" ~ field.name() ~ "("~rtype~" value,size_t size){" ~ field.name() ~"_~=value[0 .. size];}";
      }
      rst ~= "void set_" ~ field.name() ~ "(int index,"~rtype~" value){" ~ field.name() ~"_[index]=value;}";
      rst ~= "void add_" ~ field.name() ~ "("~ rtype ~" value){" ~ field.name() ~"_~=value;}";
      rst ~= "size_t " ~ field.name() ~ "_cached_size;";
    }
    return rst;
  }
  string genEnum(EnumDescriptor enum_type)
  {
    string rst;
    rst ~= "enum "~enum_type.name()~" {";
    for(int i =0;i < enum_type.value_count();i++)
    {
      rst ~= enum_type.value(i).name() ~"="~ tango.text.convert.Integer.toString(enum_type.value(i).number())~",";
    }
    rst ~= "}";

    rst ~= "size_t " ~ enum_type.name() ~ "_cached_size;";
    return rst;
  }
  string genCodeFunc(Descriptor msg)
  {
    string rst;
    rst ~= genByteCount(msg);
    /*
    rst ~= "byte* SerializeToBytes(byte* target){";
    for(int i =0;i<msg.field_count();i++) {
      if(msg.field(i).is_repeated()) {
        rst ~= genRepeatedCode(msg.field(i));
      } else {
        rst ~= genCommonCode(msg.field(i));
      }
    }
    rst ~= "return target;}";
    */
    rst ~= "void Serialize(ref CodedOutputStream output){";
    for(int i =0;i<msg.field_count();i++) {
      if(msg.field(i).is_repeated()) {
        rst ~= genRepeatedCode(msg.field(i), true);
      } else {
        rst ~= genCommonCode(msg.field(i), true);
      }
    }
    if(msg.extension_range_count() > 0)
      rst ~= "SerializeExtension(output);";
    rst ~= "if(_unknown_fields.length > 0){output.WriteRaw(_unknown_fields);}output.WriteTag(0);}";
    rst ~= "void MergePartialFromStream(ref CodedInputStream input) {uint tag;while((tag = input.ReadTag()) != 0){switch(GetTagFieldNumber(tag)){";
    rst ~= genReadCode(msg);
    rst ~= "default:{SkipField(input,tag,_unknown_fields );break;}}}";
    if(msg.extension_range_count() > 0)
      rst ~= "ZeroCopyInputStream tmp = new ZeroCopyInputStream(_unknown_fields);CodedInputStream tmp2 = new CodedInputStream(&tmp);this.ExtensionMergePartialFromStream(tmp2);";
    rst ~= "}";
    rst ~= "void MergeFrom(" ~ msg.full_name() ~ " from) {if(this == from) return;this = from ;}";
    rst ~= "void MergeFrom(Message from){if(this == from) return;byte[] coded_tmp;coded_tmp.length = from.ByteSize();byte* code_ptr = coded_tmp.ptr;from.SerializeToBytes(code_ptr);ZeroCopyInputStream ztmp = new ZeroCopyInputStream(coded_tmp);CodedInputStream tmp = new CodedInputStream(&ztmp);this.MergePartialFromStream(tmp);}";
    return rst;
  }
  string genByteCount(Descriptor msg)
  {
    string rst;
    rst  ~= "size_t ByteSize(){";
    for(int i =0;i<msg.field_count();i++) {
      string sizefunc = genGetSizeFunc(msg.field(i).type());
      if(msg.field(i).is_repeated()) {
        rst ~= "int data_size = 0;";
        rst ~= "for(int i = 0; i < " ~ msg.field(i).name() ~ ".length; i++) {";
        if(msg.field(i).is_packed) {
          rst ~= "data_size += ";
          if(sizefunc) {
            rst ~= sizefunc ~ "(" ~ msg.field(i).name() ~ "[i]);";
          } else {
            rst ~=  msg.field(i).name() ~ "[i].sizeof;";
          }
          rst ~= "}";
          rst ~= "if(data_size >0) {cached_size += 1 + Int32Size(data_size) + data_size ;}";
        } else {
          rst ~= "data_size += 1 +";
          if(sizefunc) {
            rst ~= sizefunc ~ "(" ~ msg.field(i).name() ~ "[i]);";
          } else {
            rst ~=  msg.field(i).name() ~ "[i].sizeof;";
          }
          rst ~= "}";
          rst ~= "cached_size += data_size;";
        }
        rst ~= msg.field(i).name() ~ "_cached_size=data_size;";
      } else {
        rst ~="if(has_" ~ msg.field(i).name() ~ "()){";
        rst ~= "cached_size += 1 +";
        if(sizefunc) {
          rst ~= sizefunc ~ "(" ~ msg.field(i).name() ~ ");";
        } else {
            rst ~=  msg.field(i).name() ~ ".sizeof;";
        }
        rst ~= "}";
      }
    }
    rst ~= "if(_unknown_fields){cached_size += _unknown_fields.length;}";
    rst ~= "return cached_size;}";
    return rst;
  }
  string genRepeatedCode(FieldDescriptor field, bool is_stream = false)
  {
    string rst;
    string rtype;
    rtype = GetDTypeToString(field.type());
    if(rtype is null)
      rtype = field.msg_enum();
    if(field.is_packed()) {
      rst ~= genRepeatedPackedCode(field, is_stream);
    } else {
      rst ~= genRepeatedCommonCode(field, is_stream);
    }
    return rst;
  }
  string genRepeatedCommonCode(FieldDescriptor field, bool is_stream = false)
  {
    string rtype;
    rtype = GetDTypeToString(field.type());
    if(rtype is null)
      rtype = field.msg_enum();
    string rst;
    rst ~= "for(int i = 0; i < " ~ field.name() ~ ".length; i++){";
    if(is_stream) {
      if(field.type() == FieldType.TYPE_MESSAGE) {
        rst ~= FieldTypeToFunc(field.type()) ~ "!(" ~ rtype ~ ")" ~ tango.text.convert.Integer.toString(field.number()) ~ "," ~ field.name() ~ "_[i], output);";
      } else if(field.type() == FieldType.TYPE_ENUM) {
        rst ~= FieldTypeToFunc(field.type()) ~ tango.text.convert.Integer.toString(field.number()) ~ ", cast(uint)" ~ field.name() ~ "_[i], output);";
      } else {
        rst ~= FieldTypeToFunc(field.type()) ~ tango.text.convert.Integer.toString(field.number()) ~ "," ~ field.name() ~ "_[i], output);";
      }
    } else {
      if(field.type() == FieldType.TYPE_MESSAGE) {
        rst ~= "target = " ~ FieldTypeToFunc(field.type()) ~ "!(" ~ rtype ~ ")" ~ "ToBytes(" ~ tango.text.convert.Integer.toString(field.number()) ~ "," ~ field.name() ~ "_[i], target);";
      } else if(field.type() == FieldType.TYPE_ENUM) {
        rst ~= "target = " ~ FieldTypeToFunc(field.type()) ~ "ToBytes(" ~ tango.text.convert.Integer.toString(field.number()) ~ ", cast(uint)" ~ field.name() ~ "_[i], target);";
      } else {
        rst ~= "target = " ~ FieldTypeToFunc(field.type()) ~ "ToBytes(" ~ tango.text.convert.Integer.toString(field.number()) ~ "," ~ field.name() ~ "_[i], target);";
      }
    }
    rst ~= "}";      
    return rst;
  }
  string genRepeatedPackedCode(FieldDescriptor field, bool is_stream = false)
  {
    string rtype;
    rtype = GetDTypeToString(field.type());
    if(rtype is null)
      rtype = field.msg_enum();
    string rst;
    if(is_stream) {
      rst ~= "WriteTag(" ~ tango.text.convert.Integer.toString(field.number()) ~ ", WireType.WIRETYPE_LENGTH_DELIMITED, output);";
      rst ~= "WriteUInt32NoTag(" ~ field.name() ~ "_cached_size, output);";
      rst ~= "for(int i = 0; i < " ~ field.name() ~ ".length; i++){";
      if(field.type() == FieldType.TYPE_MESSAGE) {
        rst ~= FieldTypeToFunc(field.type()) ~ "NoTag!(" ~ rtype ~ ")(" ~ field.name() ~ "_[i], output);";
      } else if(field.type() == FieldType.TYPE_ENUM) {
        rst ~= FieldTypeToFunc(field.type()) ~ "NoTag((uint)" ~ field.name() ~ "_[i], output);";
      } else {
        rst ~= FieldTypeToFunc(field.type()) ~ "NoTag(" ~ field.name() ~ "_[i], output);";
      }
    } else {
      rst ~= "target = WriteTagToBytes(" ~ tango.text.convert.Integer.toString(field.number()) ~ ", WireType.WIRETYPE_LENGTH_DELIMITED, target);";
      rst ~= "WriteUInt32NoTagToBytes(" ~ field.name() ~ "_cached_size, target);";
      rst ~= "for(int i = 0; i < " ~ field.name() ~ ".length; i++){";
      if(field.type() == FieldType.TYPE_MESSAGE) {
        rst ~= "target = " ~ FieldTypeToFunc(field.type()) ~ "NoTagToBytes!(" ~ rtype ~ ")(" ~ field.name() ~ "_[i], target);";
      } else if(field.type() == FieldType.TYPE_ENUM) {
        rst ~= "target = " ~ FieldTypeToFunc(field.type()) ~ "NoTagToBytes((uint)" ~ field.name() ~ "_[i], target);";
      } else {
        rst ~= "target = " ~ FieldTypeToFunc(field.type()) ~ "NoTagToBytes(" ~ field.name() ~ "_[i], target);";
      }
    }
    rst ~= "}";
    return rst;
  }
  string genCommonCode(FieldDescriptor field, bool is_stream = false)
  {
    string rst;
    rst ~= "if(has_" ~ field.name() ~ "){";
    if(is_stream) {
      if(field.type() == FieldType.TYPE_MESSAGE) {
        rst ~= FieldTypeToFunc(field.type()) ~ "(" ~ tango.text.convert.Integer.toString(field.number()) ~ "," ~ field.name() ~ "(), output);";
      } else if(field.type() == FieldType.TYPE_ENUM) {
        rst ~= FieldTypeToFunc(field.type()) ~ "(" ~ tango.text.convert.Integer.toString(field.number()) ~ ", cast(uint)" ~ field.name() ~ "(), output);";
      } else {
        rst ~= FieldTypeToFunc(field.type()) ~ "(" ~ tango.text.convert.Integer.toString(field.number()) ~ "," ~ field.name() ~ "(), output);";
      }
    } else {
      if(field.type() == FieldType.TYPE_MESSAGE) {
        rst ~= "target = " ~ FieldTypeToFunc(field.type()) ~ "ToBytes(" ~ tango.text.convert.Integer.toString(field.number()) ~ "," ~ field.name() ~ "(), target);";
      } else if(field.type() == FieldType.TYPE_ENUM) {
        rst ~= "target = " ~ FieldTypeToFunc(field.type()) ~ "ToBytes(" ~ tango.text.convert.Integer.toString(field.number()) ~ ", cast(uint)" ~ field.name() ~ "(), target);";
      } else {
        rst ~= "target = " ~ FieldTypeToFunc(field.type()) ~ "ToBytes(" ~ tango.text.convert.Integer.toString(field.number()) ~ "," ~ field.name() ~ "(), target);";
      }
    }
    rst ~= "}";
    if(field.is_required())
      rst ~="else {throw new Exception(\"lack field value.\");}";
    return rst;
  }
  string genReadCode(Descriptor msg)
  {
    string rst;
    for(int i = 0; i < msg.field_count(); i++)
    {
      rst ~= "case "~tango.text.convert.Integer.toString(msg.field(i).number())~":{";
      rst ~= genCommonReadCode(msg.field(i));
      rst ~= "break;}";
    }
    return rst;
  }
  string genCommonReadCode(FieldDescriptor field)
  {
    string rst;
    string rtype;
    rtype = GetDTypeToString(field.type());
    if(rtype is null)
      rtype = field.msg_enum();
    if((GetWireTypeForFieldType(field.type()) == WireType.WIRETYPE_LENGTH_DELIMITED)||(field.is_repeated)) {
      rst ~= "if((GetTagWireType(tag) == " ~ FieldTypeToWireTypeString(field.type()) ~ ")||(GetTagWireType(tag) == WireType.WIRETYPE_LENGTH_DELIMITED)){";
    } else {
      rst ~= "if(GetTagWireType(tag) == " ~ FieldTypeToWireTypeString(field.type()) ~ "){";
    }
    if(field.is_packed) {
      rst ~= "uint regen_tag = MakeTag(" ~ tango.text.convert.Integer.toString(field.number) ~ "," ~ FieldTypeToWireTypeString(field.type) ~");";
      rst ~= FieldTypeToReadFunc(field.type, field.is_repeated, field.is_packed) ~ "(UInt32Size(regen_tag), regen_tag, input," ~ field.name() ~ "_," ~ FieldTypeToString(field.type) ~ ");"; 
    } else {
      rst ~= FieldTypeToReadFunc(field.type, field.is_repeated, field.is_packed) ~ "(input," ~ field.name() ~ "_," ~ FieldTypeToString(field.type) ~ ");";
    }
    rst ~= "}else{ SkipField(input, tag, _unknown_fields);}";
    return rst;
  }
 private:
  bool has_ext;
}
string getExtensionFunc(Descriptor msg)
{
  string rst;
  rst ~="mixin Ext;";
  return rst;
}
