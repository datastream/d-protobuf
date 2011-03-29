module analysis;

private import tango.util.Convert;

import AST;
import descriptor;
import preprocessor;
import prototype;
private import commen;

private alias char[] string;

class Analysis
{
    Stmt ASTTree;
    FileDescriptor filedescriptor;
    Descriptor root_block;
    string extend_name;
    bool is_extend;
    string codemode;
    string messagemode;
    this(wordmap[] tokens,string file_name)
    {
        AST parser = new AST(tokens);
        this.ASTTree = parser.Parser();
        this.filedescriptor = new FileDescriptor;
        this.filedescriptor.set_name(file_name);
        this.root_block = null;
        this.extend_name = null;
        this.is_extend = false;
        GetAllDesciptor();
        CheckSema();
    }
    void CheckSema()
    {
        this.filedescriptor.CheckMessageSema();
    }
    void GetAllDesciptor()
    {
        if(!GetStmt())
            throw new Exception("Stat error on GetStmt() from GetAllDesciptor()");
    }
    bool GetStmt()
    {
        Stmt ASTNode;
        ASTNode = this.ASTTree;
        if(ASTTree.classinfo.name is Sequence.classinfo.name)
        {
            Sequence stat = cast(Sequence)this.ASTTree;
            this.ASTTree = stat.First;
            if(!GetStmt())
                throw new Exception(this.ASTTree.info ~ " failed in GetStmt()");
            this.ASTTree = stat.Second;
            return GetStmt();
        }
        if(ASTTree.classinfo.name is Dependency.classinfo.name)
        {
            Dependency stat = cast(Dependency)this.ASTTree;
            PreProcessor pp = new PreProcessor(stat.file[1..length-2]);
            pp.Scan();
            Analysis anl = new Analysis(pp.tokens,stat.file[1..length-2]);
            this.filedescriptor.add_dependency(anl.filedescriptor);
            return true;
        }
        if(ASTTree.classinfo.name is Options.classinfo.name)
        {
            Options stat = cast(Options)this.ASTTree;
            if(stat.option_name == "d_package")
                this.filedescriptor.set_package(stat.option_value);
            if((stat.option_name == "optimize_for")&&(this.codemode is null))
                this.codemode = stat.option_value;
            throw new Exception(this.ASTTree.info ~ " packeage or optimize failed");
            return true;
        }
        if(ASTTree.classinfo.name is Package.classinfo.name)
        {
            Package stat = cast(Package)this.ASTTree;
            this.filedescriptor.set_package(stat.name);
            return true;
        }
        if(ASTTree.classinfo.name is Message.classinfo.name)
        {
            Message stat = cast(Message)this.ASTTree;
            Descriptor dp = new Descriptor;
            dp.set_name(stat.name);
            dp.set_file(this.filedescriptor);
            dp.set_full_name(dp.name());
            this.filedescriptor.add_message(dp);
            Descriptor temp = this.root_block;
            this.root_block = dp;
            this.ASTTree = stat.nStmt;
            if(GetFieldPart1())
            {
                this.root_block = temp;
                return true;
            }
            throw new Exception(this.ASTTree.info ~ " last field end");
        }
        if(ASTTree.classinfo.name is Extend.classinfo.name)
        {
            Extend stat = cast(Extend)this.ASTTree;
            this.extend_name = stat.name;
            this.is_extend = true;
            if(GetFieldPart1())
            {
                this.extend_name = null;
                this.is_extend = false;
                return true;
            }
            else
                throw new Exception(this.ASTTree.info ~ " failed in GetFieldPart() from GetStmt()");
        }
        this.ASTTree = ASTNode;
        throw new Exception(this.ASTTree.info ~ " failed in GetStmt() end");
    }
    bool GetFieldPart1()
    {
        Stmt ASTNode;
        ASTNode = this.ASTTree;
        if(ASTTree.classinfo.name is Sequence.classinfo.name)
        {
            Sequence stat = cast(Sequence)this.ASTTree;
            this.ASTTree = stat.First;
            if(!GetFieldPart1())
                throw new Exception(this.ASTTree.info ~ " failed in GetFieldPart1().Sequence");
            this.ASTTree = ASTNode;
            this.ASTTree = stat.Second;
            return GetFieldPart1();
        }
        if(ASTTree.classinfo.name is Lable.classinfo.name)
        {
            Lable stat = cast(Lable)this.ASTTree;
            FieldDescriptor tmp = new FieldDescriptor;
            tmp.set_label(StringToLable(stat.type));
            tmp.set_extension(this.is_extend);
            tmp.set_file(this.filedescriptor);
            if(tmp.is_extension())
            {
                tmp.set_extension_scope(this.root_block);
                tmp.set_extension_name(this.extend_name);
                if(tmp.extension_scope())
                {
                    tmp.extension_scope().add_extension(tmp);
                }
                else
                    this.filedescriptor.add_extension(tmp);
                
            }
            else
            {
                tmp.set_containing_type(this.root_block);
                tmp.containing_type().add_field(tmp);
            }
            this.ASTTree = stat.nStmt;
            return GetFieldPart2();
            
        }
        if(ASTTree.classinfo.name is Enum.classinfo.name)
        {
            Enum stat = cast(Enum)this.ASTTree;
            EnumDescriptor tmp = new EnumDescriptor;
            tmp.set_name(stat.name);
            tmp.set_file( this.filedescriptor);
            tmp.set_containing_type(this.root_block);
            tmp.set_full_name( tmp.containing_type().full_name() ~ "_" ~ tmp.name());
            tmp.containing_type().add_enum_type(tmp);
            this.ASTTree = stat.nStmt;
            if(this.is_extend)
                throw new Exception(stat.info ~ " optional, required, request");
            return GetFieldEnum();
        }
        if(ASTTree.classinfo.name is Message.classinfo.name)
        {
            Message stat = cast(Message)this.ASTTree;
            Descriptor tmp = new Descriptor;
            tmp.set_name(stat.name);
            tmp.set_containing_type(this.root_block);
            tmp.set_full_name(tmp.containing_type().full_name() ~ "_" ~ tmp.name());
            tmp.containing_type().add_nested_type(tmp);
            Descriptor temp = this.root_block;
            this.root_block = tmp;
            this.ASTTree = stat.nStmt;
            if(GetFieldPart1())
            {
                this.root_block = temp;
                return true;
            }
            if(this.is_extend)
                throw new Exception(stat.info ~ " is not optional, required, request");
            throw new Exception(this.ASTTree.info ~ " failed in GetFieldpart1().Message");
        }
        if(ASTTree.classinfo.name is Extend.classinfo.name)
        {
            Extend stat = cast(Extend)this.ASTTree;
            this.extend_name = stat.name;
            this.is_extend = true;
            this.ASTTree = stat.nStmt;
            if(GetFieldPart1())
            {
                this.extend_name = null;
                this.is_extend = false;
                return true;
            }
            if(this.is_extend)
                throw new Exception(stat.info ~ " optional, required, request");
            throw new Exception(this.ASTTree.info ~ " failed in GetFieldPart1().Extend");
        }
        if(ASTTree.classinfo.name is Extensions.classinfo.name)
        {
            Extensions stat = cast(Extensions)this.ASTTree;
            Descriptor.ExtensionRange tmp;
            if(stat.end == "max")
                stat.end = "536870911";
            try
            {
                tmp.start = tango.text.convert.Integer.toInt(stat.start);
                tmp.end = tango.text.convert.Integer.toInt(stat.end);
            }
            catch(Exception e)
            {
                throw new Exception(this.ASTTree.info ~ ": extensions_range error");      
            }
            if(tmp.start > tmp.end)
                throw new Exception(this.ASTTree.info ~ " Extension range end number must be greater than start number");
            this.root_block.add_extension_range(tmp);
            if(this.is_extend)
                throw new Exception(this.ASTTree.info ~ " optional, required, request");
            return true;
        }
        this.ASTTree = ASTNode;
        if(this.is_extend)
            throw new Exception(this.ASTTree.info ~ " optional, required, request");
        throw new Exception("failed in GetFieldPart1() end");
    }
    bool GetFieldPart2()
    {
        Stmt ASTNode;
        ASTNode = this.ASTTree;
        if(ASTTree.classinfo.name is VarType.classinfo.name)
        {
            VarType stat = cast(VarType) this.ASTTree;
            if(this.is_extend)
                if(this.root_block)
                {
                    this.root_block.last_extension().set_type(StringToFieldType(stat.type));
                    if(StringToFieldType(stat.type) == FieldType.MAX_TYPE)
                        this.root_block.last_extension().set_msg_enum(stat.type);
                }
                else
                {
                    this.filedescriptor.last_extension().set_type(StringToFieldType(stat.type));
                    if(StringToFieldType(stat.type) == FieldType.MAX_TYPE)
                        this.filedescriptor.last_extension().set_msg_enum(stat.type);
                    
                }
            else
            {
                this.root_block.last_field().set_type(StringToFieldType(stat.type));
                if(StringToFieldType(stat.type) == FieldType.MAX_TYPE)
                    this.root_block.last_field().set_msg_enum(stat.type);
            }
            this.ASTTree = stat.nStmt;
            return GetFieldPart3();
        }
        if(ASTTree.classinfo.name is Sequence.classinfo.name)
        {
            Sequence stat = cast(Sequence)this.ASTTree;
            this.ASTTree = stat.First;
            if(!GetFieldPart3())
                throw new Exception(this.ASTTree.info ~ "failed in GetFieldPart2()");
            this.ASTTree = ASTNode;
            this.ASTTree = stat.Second;
            return GetFieldPart1();
        }
        this.ASTTree = ASTNode;
        throw new Exception(this.ASTTree.info ~ "failed in GetFieldPart2() end");
    }
    bool GetFieldPart3()
    {
        Stmt ASTNode;
        ASTNode = this.ASTTree;
        if(ASTTree.classinfo.name is VarPostion.classinfo.name)
        {
            VarPostion stat = cast(VarPostion)this.ASTTree;
            FieldDescriptor tmp;
            if(this.is_extend)
            {
                if(this.root_block)
                {
                    tmp = this.root_block.last_extension();
                    tmp.set_name(stat.name);
                    try
                    {
                        tmp.set_number(tango.text.convert.Integer.toInt(stat.pos));
                    }
                    catch(Exception e)
                    {
                        throw new Exception("field_number error: " ~stat.name ~":" ~ stat.pos);
                    }
                    tmp.set_full_name(tmp.extension_scope().full_name() ~ "_" ~ stat.name);
                }
                else
                {
                    tmp = this.filedescriptor.last_extension();
                    tmp.set_name(stat.name);
                    try
                    {
                        tmp.set_number(tango.text.convert.Integer.toInt(stat.pos));
                    }
                    catch(Exception e)
                    {
                        throw new Exception("field_number error: " ~stat.name ~":" ~ stat.pos);
                    }
                    tmp.set_full_name(stat.name);
                }
            }
            else
            {
                tmp = this.root_block.last_field();
                tmp.set_name(stat.name);
                tmp.set_full_name(tmp.containing_type().full_name() ~ "_" ~ stat.name);
                try
                {
                    tmp.set_number(tango.text.convert.Integer.atoi(stat.pos));
                }
                catch(Exception e)
                {
                    throw new Exception("field_number error: " ~tmp.name() ~": "~ stat.pos);
                }
            }
            this.ASTTree = stat.nStmt;
            return true;
        }
        if(ASTTree.classinfo.name is Sequence.classinfo.name)
        {
            Sequence stat = cast(Sequence)this.ASTTree;
            this.ASTTree = stat.First;
            if(!GetFieldPart3())
                throw new Exception(this.ASTTree.info ~ "failed in GetFieldPart3().Sequence");
            this.ASTTree = ASTNode;
            this.ASTTree = stat.Second;
            return GetFieldPart4();
        }
        this.ASTTree = ASTNode;
        throw new Exception(this.ASTTree.info ~ "failed in GetFieldPart3() end");
    }
    bool GetFieldPart4()
    {
        Stmt ASTNode;
        ASTNode = this.ASTTree;   
        if(ASTTree.classinfo.name is FieldAddtion.classinfo.name)
        {
            FieldAddtion stat = cast(FieldAddtion)this.ASTTree;
            FieldDescriptor tmp;
            if(stat.type == "packed")
            {
                tmp = this.root_block.last_field();
                if(!tmp.is_repeated())
                    if(stat.value == "true")
                        throw new Exception(stat.info~" [packed = true] can only be specified for repeated primitive fields.");
                if(stat.value == "true")
                    tmp.set_packed(true);
                return true;
            }
            if(stat.type == "default")
            {
                if(this.is_extend)
                {
                    if(this.root_block)
                    {
                        tmp = this.root_block.last_extension();
                        tmp.set_has_value(true);
                        try
                        {
                            tmp.setdefaultvalue(stat.value);
                        }
                        catch(Exception e)
                        {
                            throw new Exception(stat.info ~ ": value:"~stat.value ~ ": " ~ tmp.msg_enum());
                        }
                    }
                    else
                    {
                        tmp = this.filedescriptor.last_extension();
                        tmp.set_has_value(true);
                        try
                        {
                            tmp.setdefaultvalue(stat.value);
                        }
                        catch(Exception e)
                        {
                            throw new Exception(stat.info ~ ": value:"~stat.value~ ": " ~ tmp.msg_enum());
                        }
                    }   
                }
                else
                {
                    tmp = this.root_block.last_field();
                    tmp.set_has_value(true);
                    try
                    {
                        tmp.setdefaultvalue(stat.value);
                    }
                    catch(Exception e)
                    {                    
                        throw new Exception(ASTNode.info ~ ": value:"~stat.value~ " type: " ~ tmp.msg_enum()~" fullname: "~tmp.full_name());
                    }
                }
            }
            return true;
        }
        this.ASTTree = ASTNode;
        throw new Exception( this.ASTTree.info ~ "failed in GetFieldPart4() end");
    }
    bool GetFieldEnum()
    {
        Stmt ASTNode;
        ASTNode = this.ASTTree;
        if(ASTTree.classinfo.name is Sequence.classinfo.name)
        {
            Sequence stat = cast(Sequence)this.ASTTree;
            this.ASTTree = stat.First;
            if(!GetFieldEnum())
                throw new Exception(this.ASTTree.info ~ " failed in GetFieldEnum()");
            this.ASTTree = ASTNode;
            this.ASTTree = stat.Second;
            return GetFieldEnum();
        }
        if(ASTTree.classinfo.name is EnumValue.classinfo.name)
        {
            EnumValue stat = cast(EnumValue)this.ASTTree;
            EnumDescriptor tmp;
            EnumValueDescriptor tmp2 = new EnumValueDescriptor;
            tmp = this.root_block.last_enum_type();
            tmp2.set_name(stat.key);
            tmp2.set_number(tango.text.convert.Integer.toInt(stat.value));
            tmp2.set_type(tmp);
            tmp2.set_full_name(tmp.full_name() ~ "_" ~ tmp2.name());
            tmp.add_value(tmp2);
            if(this.is_extend)
                throw new Exception(stat.info ~ " optional, required, request");
            return true;
        }
        this.ASTTree = ASTNode;
        throw new Exception(this.ASTTree.info ~ "failed in GetFieldEnum() end");
    }
}
