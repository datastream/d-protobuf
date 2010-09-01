module codegen;

private import tango.io.device.File;
private import tango.text.Util;
private import tango.util.log.Log;
private import tango.util.log.Config;
import descriptor;
import writer;
import prototype;

private alias char[] string;

class CodeGen
{
    string[char[]] code;
    string package_name;
    FileDescriptor messages;
    this(FileDescriptor fd)
    {
        auto logger = Log.lookup("protobuf.log");
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
            logger.error ("Exception: " ~ x.toString);
        }
    }
    string genCode()
    {
        string rst;
        //rst ~= "package " ~this.messages.package_name()~";";
        rst ~="import wireformat;";
        for(int i = 0; i < this.messages.message_count();i++)
        {
            rst ~= genMessageCode(this.messages.message(i));
        }
        for(int i= 0; i < this.messages.extension_count(); i++)
        {
            rst ~= genFieldCode(this.messages.extension(i));
        }
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
        rst ~= "uint _has_bits_[("~ tango.text.convert.Integer.toString(n) ~" + 31) / 32];";
        rst ~= "bool has_bit(int index){return (_has_bits_[index / 32] & (1u << (index % 32))) != 0;}void set_bit(int index){_has_bits_[index / 32] |= (1u << (index % 32));}void clear_bit(int index){_has_bits_[index / 32] &= ~(1u << (index % 32));}";
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
            rst ~= getExtensionFunc(msg);
        }
        rst ~= genCodeFunc(msg);
        for(int i =0; i< msg.nested_type_count(); i++)
        {
            rst ~= genMessageCode(msg.nested_type(i));
        }
        rst ~= "}";
        return rst;
    }
    string genFieldCode(FieldDescriptor field)
    {
        string rst;
        if(field.is_extension())
        {
            string rtype;
            rtype = GetType(field.type());
            if(rtype is null)
                rtype = field.msg_enum;
            if(field.type() == Type.TYPE_ENUM)
            {
                rtype = "int";
            }
            rst ~= "static ExtensionIdentifier!("~ rtype ~(field.is_repeated()? "[]":" " )~","~rtype~") " ~ field.name() ~" = ExtensionIdentifier!("~ rtype ~(field.is_repeated()? "[]":" " )~","~rtype~")(" ~(field.is_repeated()? "true":"false")~"," ~TypeToString(field.type()) ~ ","~ tango.text.convert.Integer.toString(field.number()) ~ "," ~ (field.is_packed()?"true":"false")~(field.has_default_value()?","~field.getdefultvalue():"") ~");";
            return rst;
        }
        string rtype;
        rtype = GetType(field.type());
        if(rtype is null)
            rtype = field.msg_enum;
        if(field.type() == Type.TYPE_ENUM)
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
        case Type.TYPE_BYTES:
        case Type.TYPE_STRING:
            {
                rst ~= genString(field,i);
                break;
            }
        case Type.TYPE_INT32:
        case Type.TYPE_INT64:
        case Type.TYPE_UINT32:
        case Type.TYPE_UINT64:
        case Type.TYPE_SINT32:
        case Type.TYPE_SINT64:
        case Type.TYPE_FIXED32:
        case Type.TYPE_FIXED64:
        case Type.TYPE_SFIXED32:
        case Type.TYPE_SFIXED64:
        case Type.TYPE_DOUBLE:
        case Type.TYPE_FLOAT:
        case Type.TYPE_BOOL:
        case Type.TYPE_ENUM:
            {
                rst ~= genDigital(field,i);
                break;
            }
        case Type.TYPE_MESSAGE:
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
        rtype = GetType(field.type());
        if(rtype is null)
            rtype = field.msg_enum();
        if(field.type() == Type.TYPE_ENUM)
            rst ~= rtype ~ (field.is_repeated()?"[] ":" ") ~field.name() ~ "(){return cast("~ field.default_value_enum().type().name() ~")" ~field.name() ~ "_;}";
        else
            rst ~= rtype ~ (field.is_repeated()?"[] ":" ") ~field.name() ~ "(){return "~ field.name() ~ "_;}";
        if(!field.is_repeated())
        {
            rst ~= "bool has_" ~ field.name() ~ "(){return has_bit(" ~ tango.text.convert.Integer.toString(i) ~ ");}";
            if(field.has_default_value())
            {
                if(field.type() == Type.TYPE_ENUM)
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
        }
        return rst;
    }
    string genObject(FieldDescriptor field,int i)
    {
        string rst;
        string rtype;
        rtype = GetType(field.type());
        if(rtype is null)
            rtype = field.msg_enum();
        if(field.type() == Type.TYPE_ENUM)
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
        }
        return rst;
    }
    string genString(FieldDescriptor field, int i)
    {
        string rst;
        string rtype;
        rtype = GetType(field.type());
        if(rtype is null)
            rtype = field.msg_enum();
        if(field.type() == Type.TYPE_ENUM)
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
            if(field.type() == Type.TYPE_BYTES)
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
            if(field.type() == Type.TYPE_BYTES)
            {
                rst ~= rtype ~ " mutable"~ field.name() ~ "(int index){return "~ field.name() ~ "_[index].dup;}";
                rst ~= "void set_" ~ field.name() ~ "(int index,"~rtype~" value,size_t size){" ~ field.name() ~"_[index]=value[0 .. size];}";
                rst ~= "void add_" ~ field.name() ~ "("~rtype~" value,size_t size){" ~ field.name() ~"_~=value[0 .. size];}";
            }
            rst ~= "void set_" ~ field.name() ~ "(int index,"~rtype~" value){" ~ field.name() ~"_[index]=value;}";
            rst ~= "void add_" ~ field.name() ~ "("~ rtype ~" value){" ~ field.name() ~"_~=value;}";
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
        return rst;
    }
    string genCodeFunc(Descriptor msg)
    {
        string rst;
        rst ~= "byte[] Serialize(){byte[] rst;";
        for(int i =0;i<msg.field_count();i++)
        {
            if(!msg.field(i).is_repeated())
            {
                rst ~= "if(has_"~ msg.field(i).name()~")\n";
                if(msg.field(i).type() == Type.TYPE_MESSAGE)
                    rst ~="rst ~=  "~TypeToFunc(msg.field(i).type(),msg.field(i).is_packed())~"("~msg.field(i).name()~"().Serialize(),"~tango.text.convert.Integer.toString(msg.field(i).number())~","~TypeToString(msg.field(i).type())~");";
                else
                {
                    if(msg.field(i).type() == Type.TYPE_ENUM)
                        rst ~= "rst ~= "~TypeToFunc(msg.field(i).type(),msg.field(i).is_packed())~"(cast(uint)"~msg.field(i).name()~"(),"~tango.text.convert.Integer.toString(msg.field(i).number())~","~TypeToString(msg.field(i).type())~");";
                    else
                        rst ~= "rst ~= "~TypeToFunc(msg.field(i).type(),msg.field(i).is_packed())~"("~msg.field(i).name()~"(),"~tango.text.convert.Integer.toString(msg.field(i).number())~","~TypeToString(msg.field(i).type())~");";
                }
            }
            else
            {
                string rtype;
                rtype = GetType(msg.field(i).type());
                if(rtype is null)
                    rtype = msg.field(i).msg_enum();
                if(msg.field(i).is_packed())
                {
                    rst ~= "rst ~= "~TypeToFunc(msg.field(i).type(),msg.field(i).is_packed())~"("~msg.field(i).name()~"_,"~tango.text.convert.Integer.toString(msg.field(i).number())~","~TypeToString(msg.field(i).type())~");";
                }
                else
                {
                    rst ~= "foreach("~rtype~" iter;"~msg.field(i).name()~"_){";
                    if(msg.field(i).type() == Type.TYPE_MESSAGE)
                        rst ~= "rst ~= "~TypeToFunc(msg.field(i).type(),msg.field(i).is_packed())~"(iter.Serialize(),"~tango.text.convert.Integer.toString(msg.field(i).number())~","~TypeToString(msg.field(i).type())~");}";
                    else
                        rst ~= "rst ~= "~TypeToFunc(msg.field(i).type(),msg.field(i).is_packed())~"(iter,"~tango.text.convert.Integer.toString(msg.field(i).number())~","~TypeToString(msg.field(i).type())~");}";
                }
            }
            if(msg.field(i).is_required())
                rst ~="else\n throw new Exception(\""~msg.field(i).full_name()~" is required,but not value\");";
        }
        rst ~= "rst ~= _unknown_fields;return rst;}";
        rst ~="static "~msg.name() ~" Deserialize(ref byte[] input){return new "~msg.name()~"(input);}";
        rst ~="this(){}this(ref byte[] input){while(input.length>0){uint tag = GetTag(input);byte[] value = GetFieldValue(input,tag);switch(GetTagFieldNumber(tag)){";
        for(int i =0;i<msg.field_count();i++)
        {
            string rtype;
            rtype = GetType(msg.field(i).type());
            if(rtype is null)
                rtype = msg.field(i).msg_enum();
            rst ~= "case "~tango.text.convert.Integer.toString(msg.field(i).number())~":\n";
            if(msg.field(i).is_repeated())
            {
                rst ~= "if(GetTagWireType(tag)!=GetWireTypeForFieldType("~TypeToString(msg.field(i).type())~"))\nthrow new Exception(\"message not match\");";
                if(msg.field(i).is_packed())
                {
                    if((msg.field(i).type() == Type.TYPE_MESSAGE)||(msg.field(i).type() == Type.TYPE_STRING)||(msg.field(i).type() == Type.TYPE_BYTES))
                        rst ~= "byte[] vl = value;";
                    else
                        rst ~="int len = Decode!(uint)(value);byte[] vl = input[0..len];input= input[len..length];";
                    rst ~= "while(vl.length>0){value = GetFieldValue(vl,tag);";
                }
                if(msg.field(i).type() != Type.TYPE_MESSAGE)
                {
                    if(msg.field(i).type() == Type.TYPE_ENUM)
                        rst ~= "add_"~msg.field(i).name()~"(cast("~ msg.field(i).default_value_enum().type().name() ~")"~ ReadValueFunc(msg.field(i).type())~");";
                    else
                        rst ~= "add_"~msg.field(i).name()~"("~ ReadValueFunc(msg.field(i).type())~");";
                }
                else
                    rst ~= "add_"~msg.field(i).name()~"("~msg.field(i).name() ~"_.Deserialize(value));";
                if(msg.field(i).is_packed())
                    rst ~= "}";
            }
            else
            {
                rst ~= "if(GetTagWireType(tag)!=GetWireTypeForFieldType("~TypeToString(msg.field(i).type())~"))\nthrow new Exception(\"message not match\");";
                if(msg.field(i).type() != Type.TYPE_MESSAGE)
                {
                    if(msg.field(i).type() == Type.TYPE_ENUM)
                        rst ~= "set_"~msg.field(i).name()~"(cast("~ msg.field(i).default_value_enum().type().name() ~")"~ ReadValueFunc(msg.field(i).type())~");";
                    else
                        rst ~= "set_"~msg.field(i).name()~"("~ReadValueFunc(msg.field(i).type())~");";
                }
                else
                    rst ~= "set_"~msg.field(i).name()~"("~msg.field(i).name()~"_.Deserialize(value));";
            }
            rst ~="break;";
        }
        rst ~="default:\n if(GetTagWireType(tag)!=WireType.WIRETYPE_LENGTH_DELIMITED)_unknown_fields ~=EncodeBuf(tag)~value ;else _unknown_fields ~= EncodeBuf(tag)~EncodeBuf(value.length)~value;}}}";
        return rst;
    }
}

string getExtensionFunc(Descriptor msg)
{
    string rst;
    rst ~="import extension;"~"mixin Ext;";
    return rst;
}
