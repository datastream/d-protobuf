module descriptor;

private import tango.io.Stdout;
private import tango.util.Convert;
private import tango.text.Util;
private import tango.stdc.posix.stdlib;
private import prototype;
private import commen;
private alias char[] string;

class DescriptorPool
{
    /*
    DescriptorPool generated_pool()
    {
    }
    FileDescriptor FindFileByName(string name)
    {
    }
    FileDescriptor FindFileContainingSymbol(string symbol_name)
    {
    }
    Descriptor FindMessageTypeByName(string name);
    FieldDescriptor FindFieldByName(string name);
    FieldDescriptor FindExtensionByName(string name);
    EnumDescriptor FindEnumTypeByName(string name);
    EnumValueDescriptor FindEnumValueByName(string name);
    //ServiceDescriptor FindServiceByName(string name);
    //MethodDescriptor FindMethodByName(string name);
    FieldDescriptor FindExtensionByNumber(Descriptor extendee,int number);
    */
    this(DescriptorPool pool)
    {
    }
}

class FileDescriptor
{
    Descriptor FindMessageTypeByName(string name)
    {
        string[] namelist = split(name,".");
        if(namelist.length >1)
        {
            foreach(FileDescriptor a; dependencies_)
            {
                if(a.name() == namelist[0])
                {
                    string subname;
                    namelist = namelist[1..length];
                    for(int i =0 ; i< namelist.length; i++)
                    {
                        if(i == (name.length -1))
                            subname ~= namelist[i];
                        subname ~= namelist[i] ~ ".";
                    }
                    return a.FindMessageTypeByName(subname);
                }
            }
            foreach(Descriptor a;message_types_)
            {
                if (a.name() == namelist[0])
                {
                    string subname;
                    namelist = namelist[1..length];
                    for(int i =0 ; i< namelist.length; i++)
                    {
                        if(i == (name.length -1))
                            subname ~= namelist[i];
                        subname ~= namelist[i] ~ ".";
                    }
                    return a.FindNestedTypeByName(subname);
                }
            }
        }
        else
        {
            foreach(FileDescriptor a; dependencies_)
            {
                return a.FindMessageTypeByName(name);
            }
            foreach(Descriptor a;message_types_)
            {
                if (a.name_ == name)
                    return a;
            }
        }
        return null;
    }
    void CheckMessageSema()
    {
        int[string] count;
        if(package_name() is null)
        {
            string tmp;
            for(int i= 0;i < name_.length;i++)
            {
                if(name_[i] == '.')
                    break;
                tmp ~=name_[i];
            }
            set_package(tmp);
        }
        foreach(Descriptor a;message_types_)
        {
            count[a.name()] ++;
            if(count[a.name()]>1)
            {
                throw new Exception(a.name() ~ " define twice");
            }
            a.CheckFieldSema();
            a.CheckEnumNameSema();
            a.CheckNestSema();
        }
        foreach(FileDescriptor a;dependencies_)
        {
            a.CheckMessageSema();
            for(int i =0;i < a.message_count(); i++)
            {
                count[a.message(i).name()] ++;
                if(count[a.message(i).name()]>1)
                {
                    throw new Exception(a.message(i).name() ~ " define twice");
                }
                a.message(i).CheckFieldSema();
            }
        }
        int[string] count2;
        Descriptor[string] count3;
        int[int] pos;
        Descriptor[int] pos1;
        foreach(FieldDescriptor outer;extensions_)
        {
            outer.FixContaining();
            outer.FixFieldType();
            outer.CheckFieldRange();
            count2[outer.name()]++;
            pos[outer.number()] ++;
            if(count2[outer.name()] < 2)
                count3[outer.name()] = outer.containing_type_;
            else
                if(count3[outer.name()] == outer.containing_type_)
                    throw new Exception(outer.field_name_ ~ " defined twice");
            if(pos[outer.number()] < 2)
                pos1[outer.number()] = outer.containing_type_;
            else
                if(pos1[outer.number()] == outer.containing_type_)
                    throw new Exception(outer.name() ~ " defined twice");
            Descriptor tmp = outer.containing_type_;
            foreach(FieldDescriptor inner;tmp.fields_)
            {
                if(outer.name() == inner.name())
                {
                    throw new Exception(outer.name() ~ " define twice");
                }
            }
        }
    }
    string name()
    {
        return name_;
    }
    string package_name()
    {
        return package_;
    }
    int dependency_count()
    {
        return dependencies_.length;
    }
    FileDescriptor dependency(int index)
    {
        return dependencies_[index];
    }
    Descriptor message(int index)
    {
        return message_types_[index];
    }
    int message_count()
    {
        return message_types_.length;
    }
    int extension_count()
    {
        return extensions_.length;
    }
    FieldDescriptor extension(int index)
    {
        return extensions_[index];
    }
    void set_name(string name)
    {
        name_ = name;
    }
    void set_package(string name)
    {
        package_ = name;
    }
    void add_dependency(FileDescriptor name)
    {
        dependencies_ ~= name;
    }
    void add_message(Descriptor name)
    {
        message_types_ ~= name;
    }
    void add_extension(FieldDescriptor name)
    {
        extensions_ ~= name;
    }
    FileDescriptor last_dependecy()
    {
        return dependencies_[length -1];
    }
    Descriptor last_message()
    {
        return message_types_[length-1];
    }
    FieldDescriptor last_extension()
    {
        return extensions_[length -1];
    }
private:
    string name_;            //file name
    string package_;         //keyword package
    DescriptorPool pool_;    //include by which pool
    FileDescriptor[] dependencies_; //imported files
    Descriptor[] message_types_;  //messages
    FieldDescriptor[] extensions_; //extensions field
}
class Descriptor
{
    void CheckEnumNameSema()
    {
        int[string] count;
        foreach(EnumDescriptor a; enum_types_)
        {
            count[a.name()] ++;
            if(count[a.name()] >1)
                throw new Exception(a.name() ~ " defined twice in " ~ full_name());
            a.CheckEnumValue();
        }
    }
    void CheckFieldSema()
    {
        int[string] count;
        int[int] count1;
        foreach(FieldDescriptor a;fields_)
        {
            a.FixFieldType();
            a.CheckFieldRange();
            count[a.name()] ++;
            if(count[a.name()]>1)
            {
                throw new Exception(a.name() ~ " define twice in " ~ full_name());
            }
            count1[a.number()] ++;
            if(count1[a.number()] >1)
            {
                throw new Exception(tango.text.convert.Integer.toString(a.number()) ~ " field_number has been used in " ~ full_name());
            }
        }
        foreach(FieldDescriptor a;extensions_)
        {
            count[a.name()] ++;
            if(count[a.name()]>1)
            {
                throw new Exception(a.name()~" define twice in "~ full_name());
            }
        }
        int[string] count2;
        Descriptor[string] count3;
        int[int] pos;
        Descriptor[int] pos1;
        foreach(FieldDescriptor outer;extensions_)
        {
            outer.FixContaining();
            outer.FixFieldType();
            outer.CheckFieldRange();
            count2[outer.name()]++;
            pos[outer.number()] ++;
            if(count2[outer.name()] < 2)
                count3[outer.name()] = outer.containing_type_;
            else
                if(count3[outer.name()] == outer.containing_type_)
                    throw new Exception(outer.name() ~ " defined twice in extension " ~ outer.containing_type().full_name());
            if(pos[outer.number()] < 2)
                pos1[outer.number()] = outer.containing_type_;
            else
                if(pos1[outer.number()] == outer.containing_type_)
                    throw new Exception(tango.text.convert.Integer.toString(outer.number()) ~ " defined twice in extension "~outer.containing_type().full_name());
            Descriptor tmp = outer.containing_type();
            foreach(FieldDescriptor inner;tmp.fields_)
            {
                if(outer.name() == inner.name())
                {
                    throw new Exception(outer.name() ~ " define twice in message " ~ outer.containing_type().full_name());
                }
            }
        }
    }
    void CheckNestSema()
    {
        foreach(Descriptor a; nested_types_)
        {
            a.CheckFieldSema();
            a.CheckNestSema();
            a.CheckEnumNameSema();
        }
    }
    string name()
    {
        return name_;
    }
    string full_name()
    {
        return full_name_;
    }
    FileDescriptor file()
    {
        return file_;
    }
    Descriptor containing_type() //owned_by
    {
        return containing_type_;
    }
    int field_count()
    {
        return fields_.length;
    }
    FieldDescriptor field(int index)
    {
        return fields_[index];
    }
    FieldDescriptor FindFieldByNumber(int number)
    {
        for(int i = 0; i < field_count(); i++ )
        {
            if(fields_[i].number() == number)
                return fields_[i];
        }
        return null;
    }
    FieldDescriptor FindFieldByName(string name)
    {
        for(int i = 0; i < field_count(); i++ )
        {
            if(fields_[i].name() == name)
                return fields_[i];
        }
        return null;
    }

    // Nested type stuff -----------------------------------------------
    int nested_type_count()
    {
        return nested_types_.length;
    }
    Descriptor nested_type(int index)
    {
        return nested_types_[index];
    }
    Descriptor FindNestedTypeByName(string name)
    {
        string[] namelist = split(name,".");
        if(namelist.length >1)
        {
            for(int i = 0; i< nested_type_count(); i++)
            {
                if(nested_types_[i].name() == namelist[0])
                {
                    string subname;
                    namelist = namelist[1..length];
                    for(int n =0 ; n< namelist.length; n++)
                    {
                        if(n == (name.length -1))
                            subname ~= namelist[n];
                        subname ~= namelist[n] ~ ".";
                    }
                    return nested_types_[i].FindNestedTypeByName(subname);
                }
            }
        }
        else
        {
            for(int i = 0; i< nested_type_count(); i++)
            {
                if(nested_types_[i].name() == name)
                    return nested_types_[i];
            }
        }
        return null;
    }    

    // Enum stuff ------------------------------------------------------
    int enum_type_count()
    {
        return enum_types_.length;
    }
    EnumDescriptor enum_type(int index)
    {
        return enum_types_[index];
    }
    EnumDescriptor FindEnumTypeByName(string name)
    {
        string[] namelist = split(name,".");
        if(namelist.length >1)
        {
            string subname;
            string ename;
            ename = namelist[length-1];
            namelist = namelist[0..length-1];
            for(int n =0 ; n< namelist.length; n++)
            {
                if(n == (name.length -1))
                    subname ~= namelist[n];
                subname ~= namelist[n] ~ ".";
            }
            Descriptor tmp = file_.FindMessageTypeByName(subname);
            if(tmp)
                return tmp.FindEnumTypeByName(ename);
        }
        else
        {
            for(int i = 0; i < enum_type_count(); i++ )
            {
                if(enum_types_[i].name() == name)
                    return enum_types_[i];
            }
        }
        return null;
    }
    EnumValueDescriptor FindEnumValueByName(string name)
    {
        for(int i = 0; i < enum_type_count(); i++ )
        {
            for(int l = 0; l< enum_types_[i].value_count(); l++)
                if(enum_types_[i].values_[l].name() == name)
                    return enum_types_[i].values_[l];
        }
        return null;        
    }
    struct ExtensionRange {
        int start;  // inclusive
        int end;    // exclusive
    };
    int extension_range_count()
    {
        return extension_ranges_.length;
    }
    ExtensionRange extension_range(int index)
    {
        return extension_ranges_[index];
    }
    bool IsExtensionNumber(int number)
    {
        for(int i = 0; i< extension_count(); i++)
        {
            if((number > extension_ranges_[i].start)&&(number < extension_ranges_[i].end))
                return true;
        }
        return false;
    }
    int extension_count()
    {
        return extensions_.length;
    }
    FieldDescriptor extension(int index)
    {
        return extensions_[index];
    }
    FieldDescriptor FindExtensionByName(string name)
    {
        for(int i = 0; i < extension_count(); i++ )
        {
            if(extensions_[i].name() == name)
                return extensions_[i];
        }
        return null;
    }
    void set_name(string name)
    {
        name_ = name;
    }
    void set_full_name(string name)
    {
        full_name_ = name;
    }
    void set_file(FileDescriptor name)
    {
        file_ = name;
    }
    void set_containing_type(Descriptor name)
    {
        containing_type_ = name;
    }
    void add_field(FieldDescriptor field)
    {
        fields_ ~= field;
    }
    FieldDescriptor last_field()
    {
        return fields_[length -1];
    }
    void add_nested_type(Descriptor name)
    {
        nested_types_ ~= name;
    }
    Descriptor last_nested_type()
    {
        return nested_types_[length -1];
    }
    void add_extension_range(ExtensionRange name)
    {
        extension_ranges_ ~= name;
    }
    void add_extension(FieldDescriptor name)
    {
        extensions_ ~= name;
    }
    FieldDescriptor last_extension()
    {
        return extensions_[length -1];
    }
    void add_enum_type(EnumDescriptor name)
    {
        enum_types_ ~= name;
    }
    EnumDescriptor last_enum_type()
    {
       return enum_types_[length -1];
    }
private:
    string name_;  //message name
    FileDescriptor file_;
    string full_name_;  //message fullname
    Descriptor containing_type_; //owned by
    FieldDescriptor[] fields_;
    Descriptor[] nested_types_; //include message
    EnumDescriptor[] enum_types_; //include enums
    ExtensionRange[] extension_ranges_; //defined extension
    FieldDescriptor[] extensions_; //extension fields
}
class FieldDescriptor
{
    void FixContaining()
    {
        if(is_extension())
        {
            Descriptor tmp = extension_scope();
            while(tmp)
            {
                Descriptor tmp2 = tmp;
                tmp = tmp.FindNestedTypeByName(extension_name_);
                if(tmp)
                {
                    containing_type_ = tmp;
                    break;
                }
                tmp = tmp2;
                tmp = tmp.containing_type();
            }
            if(tmp is null)
            {
                tmp = file_.FindMessageTypeByName(extension_name_);
                containing_type_ = tmp;
                if(tmp is null)
                    throw new Exception(extension_name_ ~" not defined");
            }
        }
    }
    /*this()
    {
        is_packed_ = false;
        has_default_value_ = false;
        is_extension_ = false;
        }*/
    Descriptor FindMessageType()
    {
       Descriptor tmp;
       tmp = containing_type();
       while(tmp)
       {
           Descriptor tmp2 = tmp;
           tmp = tmp.FindNestedTypeByName(msg_enum);
           if(tmp)
           {
               return tmp;
           }
           tmp = tmp2;
           tmp = tmp.containing_type();
       }
       if(tmp is null)
       {
           tmp = file_.FindMessageTypeByName(msg_enum);
           if(tmp)
           {
               return tmp;
           }
       }
       return null;
    }
    EnumDescriptor FindEnumType()
    {
        Descriptor tmp;
        tmp = containing_type_;
        while(tmp)
        {
            EnumDescriptor tmp1;
            tmp1 = tmp.FindEnumTypeByName(msg_enum);
            if(tmp1)
            {
                return  tmp1;
            }
            tmp = tmp.containing_type();
        }
        return null;
    }
    void FixFieldType()
    {
        if(field_type_ == FieldType.MAX_TYPE)
        {
            Descriptor tmp;
            tmp = FindMessageType();
            if(tmp)
            {
                field_type_ = StringToFieldType("message");
                if(has_default_value())
                    throw new Exception("message type can't set default value "~default_value_string_);
                return;
            }
            else
            {
                EnumDescriptor tmp2;
                tmp2 = FindEnumType();
                if(tmp2)
                {
                    field_type_ = StringToFieldType("enum");
                    if(has_default_value())
                        setdefaultvalue(default_value_string_);
                    return;
                }
                else
                    throw new Exception(msg_enum ~ "is not defined");            
            }
        }
    }
    void CheckFieldRange()
    {
        Descriptor.ExtensionRange[] tmp;
        tmp = containing_type_.extension_ranges_;
        for(int i = 0; i< tmp.length; i++)
        {
            if(is_extension())
            {
                if((field_number_ < tmp[i].start)||(field_number_> tmp[i].end))
                    throw new Exception(tango.text.convert.Integer.toString(field_number_)~" is out of range in"~containing_type_.full_name_);
            }
            else
            {
                if((field_number_ > tmp[i].start)&&(field_number_ < tmp[i].end))
                    throw new Exception(tango.text.convert.Integer.toString(field_number_)~" is in range in "~containing_type_.full_name_);
            }
        }
    }
    void set_label(Label label)
    {
        field_label_ = label;
    }
    void set_type(FieldType tp)
    {
        field_type_ = tp;
    }
    void set_name(string name )
    {
        field_name_ = name;
    }
    void set_number(int num)
    {
        field_number_ = num;
    }
    void set_full_name(string name)
    {
        full_name_ = name;
    }
    void set_has_value(bool stat)
    {
        has_default_value_ = stat;
    }
    void set_extension(bool stat)
    {
        is_extension_ = stat;
    }
    void set_file(FileDescriptor name)
    {
        file_ = name;
    }
    void set_containing_type(Descriptor name)
    {
        containing_type_ = name;
    }
    void set_extension_name(string name)
    {
        extension_name_ = name;
    }
    void set_extension_scope(Descriptor name)
    {
        extension_scope_ = name;
    }
    string full_name()
    {
        return full_name_;
    }
    FileDescriptor file()
    {
        return file_;
    }
    bool is_extension()
    {
        return is_extension_;
    }
    Label label()
    {
        return field_label_;
    }
    FieldType type()
    {
        return field_type_;
    }
    string name()
    {
        return field_name_;
    }
    int number()
    {
        return field_number_;
    }
    string msg_enum()
    {
        return msg_enum_;
    }
    void set_msg_enum(string name)
    {
        msg_enum_ = name;
    }
    bool is_required()
    {
        return (field_label_ == Label.LABEL_REQUIRED);
    }
    bool is_optional()
    {
        return (field_label_ == Label.LABEL_OPTIONAL);
    }
    bool is_repeated()
    {
        return (field_label_ == Label.LABEL_REPEATED);
    }
    bool is_packed()
    {
        return is_packed_;
    }
    void set_packed(bool value)
    {
        is_packed_ = value;
    }
    bool has_default_value()
    {
        return has_default_value_;
    }
    int default_value_int32()
    {
        return default_value_int32_;
    }
    uint default_value_uint32()
    {
        return default_value_uint32_;
    }
    long default_value_int64()
    {
        return default_value_int64_;
    }
    ulong default_value_uint64()
    {
        return default_value_uint64_;
    }
    float default_value_float()
    {
        return default_value_float_;
    }
    double default_value_double()
    {
        return default_value_double_;
    }
    bool default_value_bool()
    {
        return default_value_bool_;
    }
    string default_value_string()
    {
        return default_value_string_;
    }
    EnumValueDescriptor default_value_enum()
    {
        return default_value_enum_;
    }    
    Descriptor containing_type() //owned_by if field is a extended type
    {
        return containing_type_;
    }
    
    // An extension may be declared within the scope of another message.  If this
    // field is an extension (is_extension() is true), then extension_scope()
    // returns that message, or NULL if the extension was declared at global
    // scope.  If this is not an extension, extension_scope() is undefined (may
    // assert-fail).
    Descriptor extension_scope()
    {
        return extension_scope_;
    }
    Descriptor message_type()
    {
        return containing_type_;
    }
    EnumDescriptor enum_type()
    {
        return default_value_enum_.type_;
    }
    void setdefaultvalue(string value)
    {
        if(field_label_ == Label.LABEL_REPEATED)
            throw new Exception(field_name_~"is Repeated fields,it can't have default values");
        switch(d_type(field_type_))
        {
        case DType.DTYPE_DOUBLE:
            {
                default_value_double_ = strtod(value.ptr,null);
                break;
            }
        case DType.DTYPE_FLOAT:
            {
                default_value_float_ = tango.text.convert.Float.toFloat(value);
                break;
            }
        case DType.DTYPE_UINT:
            {
                default_value_uint32_ = tango.text.convert.Integer.atoi(value);
                break;
            }
        case DType.DTYPE_INT:
            {
                default_value_int32_ = tango.text.convert.Integer.toInt(value);
                break;
            }
        case DType.DTYPE_ULONG:
            {
                default_value_uint64_ = tango.text.convert.Integer.convert(value);
                break;
            }
        case DType.DTYPE_LONG:
            {
                default_value_int64_ = tango.text.convert.Integer.toLong(value);
                break;
            }
        case DType.DTYPE_STRING:
            {
                if((value[0] != '\"') || (value[length -1] != '\"') ||(value.length <3) )
                    throw new Exception(value ~ " is not a string");
                default_value_string_ = value;
                break;
            }
        case DType.DTYPE_BOOL:
            {
                if(value == "true")
                    default_value_bool_ = true;
                else 
                    if(value == "false")
                        default_value_bool_ = false;
                    else
                        throw new Exception(value ~ " should be true/false");
                break;
            }
        case DType.DTYPE_ENUM:
            {
                Descriptor owner = containing_type_;
                EnumDescriptor tmp;
                while(owner)
                {
                    tmp = owner.FindEnumTypeByName(msg_enum);
                    if(tmp)
                        break;
                    owner = owner.containing_type_;
                }
                if(tmp is null)
                    throw new Exception(msg_enum~"Enum not defined");
                for(int i = 0; i < tmp.values_.length; i++)
                {
                    if(tmp.values_[i].name() == value)
                    {
                        default_value_enum_ = tmp.values_[i];
                        return;
                    }
                }
                throw new Exception(value ~ "is not defined in" ~ field_name_);
                break;
            }
        case DType.MAX_DTYPE:
            {
                default_value_string_ = value;
                break;
            }
        default:
            {
                throw new Exception(value ~ "is not defined in" ~ field_name_);
            }
        }
    }
    string getdefultvalue()
    {
        switch(d_type(type()))
        {
        case DType.DTYPE_DOUBLE:
            return tango.text.convert.Float.toString(default_value_double());
        case DType.DTYPE_FLOAT:
            return tango.text.convert.Float.toString(default_value_float());
        case DType.DTYPE_UINT:
            return tango.text.convert.Integer.toString(default_value_uint32());
        case DType.DTYPE_INT:
            return tango.text.convert.Integer.toString(default_value_int32());
        case DType.DTYPE_ULONG:
            return tango.text.convert.Integer.toString(default_value_uint64());
        case DType.DTYPE_LONG:
            return tango.text.convert.Integer.toString(default_value_int64());
        case DType.DTYPE_STRING:
            return default_value_string();
        case DType.DTYPE_BOOL:
            return tango.text.convert.Integer.toString(default_value_bool());
        case DType.DTYPE_ENUM:
            {
                return default_value_enum().type().name()~"."~ default_value_enum().name();
            }
        default:
            return null;
        }
    }
private:
    Label field_label_;  //requried options
    FieldType field_type_;    //data type
    string field_name_;  //var name
    string full_name_;  //full var name
    int field_number_;   //index of field in defined message
    string msg_enum_;
    bool has_default_value_; //has default value
    bool is_packed_;  //packed
    bool is_extension_;    //is extension
    FileDescriptor file_;  //in which files
    Descriptor containing_type_; //owned_by
    string extension_name_;
    Descriptor extension_scope_; //include by message,just scope related
    union {
        int  default_value_int32_;
        long  default_value_int64_;
        uint default_value_uint32_;
        ulong default_value_uint64_;
        float  default_value_float_;
        double default_value_double_;
        bool   default_value_bool_;
        EnumValueDescriptor default_value_enum_;
        string default_value_string_;
    };
}

class EnumDescriptor
{
    void CheckEnumValue()
    {
        int[string] count;
        int[int] count2;
        foreach(EnumValueDescriptor a; values_)
        {
            count[a.name()] ++;
            count2[a.number()] ++;
            if(count[a.name()] >1)
                throw new Exception(a.name() ~" defined twice in "~ full_name());
            if(count2[a.number()] >1)
                throw new Exception(tango.text.convert.Integer.toString(a.number()) ~" defined twice in "~ full_name());
        }
    }
    string name()
    {
        return name_;
    }
    string full_name()
    {
        return full_name_;
    }
    int index()
    {
        for(int i = 0 ;i < containing_type_.enum_type_count(); i++)
        {
            if(containing_type_.enum_types_[i].name() == name_)
                return i;
        }
    }
    FileDescriptor file()
    {
        return file_;
    }
    int value_count()
    {
        return values_.length;
    }
    EnumValueDescriptor value(int index)
    {
        return values_[index];
    }
    EnumValueDescriptor FindValueByNumber(int number)
    {
        for(int i = 0 ;i < value_count(); i++)
        {
            if(values_[i].number() == number)
                return values_[i];
        }
        return null;
    }
    Descriptor containing_type() //owned_by
    {
        return containing_type_;
    }
    void set_name(string name)
    {
        name_ = name;
    }
    void set_full_name(string name)
    {
        full_name_ = name;
    }
    void set_file(FileDescriptor name)
    {
        file_ = name;
    }
    void set_containing_type(Descriptor name)
    {
        containing_type_ = name;
    }
    void add_value(EnumValueDescriptor value)
    {
        values_ ~= value;
    }
    EnumValueDescriptor last_value()
    {
        return values_[length -1];
    }
    string name_;
    string full_name_;
    FileDescriptor file_; //in which file
    EnumValueDescriptor[] values_;  //values
    Descriptor containing_type_; //owned by
}
class EnumValueDescriptor
{
    string name()
    {
        return name_;
    }
    int number()
    {
        return number_;
    }
    string full_name() //google.protobuf.FieldDescriptorProto.TYPE_INT32
    {
        return full_name_;
    }
    EnumDescriptor type()
    {
        return type_;
    }
    void set_name(string name)
    {
        name_ = name;
    }
    void set_full_name(string name)
    {
        full_name_ = name;
    }
    void set_number(int num)
    {
        number_ = num;
    }
    void set_type(EnumDescriptor name)
    {
        type_ = name;
    }
    int index()
    {
        for(int i = 0 ; i < type_.value_count(); i++)
        {
            if(type_.values_[i].name() == name_)
                return i;
        }
    }
    string name_; //enmu key name
    string full_name_;
    int number_; //value
    EnumDescriptor type_; //owned by which enum
}
