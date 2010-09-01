module AST;

private import tango.stdc.ctype;

import prototype;

class AST
{
    static int index;
    wordmap[] tokens;
    Stmt result;
    this(wordmap[] tokens)
    {
        this.tokens = tokens;
        this.index = 0;
    }
    Stmt Parser()
    {
        if (this.index == this.tokens.length)
            throw new Exception("AST expected EOF in Parser()");
        this.result = this.ParseStmt();
        while(this.index < this.tokens.length)
        {
            if(this.index == (this.tokens.length -1))
                break;
            Sequence sequence = new Sequence;
            sequence.First = this.result;            
            sequence.Second = this.ParseStmt();
            this.result = sequence;
        }
        return this.result;
    }
    Stmt ParseStmt()
    {
        if (this.index == this.tokens.length)
        {
            throw new Exception("AST expected EOF in ParserStmt()");
        }
        switch(tokens[this.index].token)
        {
        case "message":
            {
                Message message = new Message;
                this.index ++;
                message.name = tokens[this.index].token;
                message.info = tokens[this.index].info;
                this.index ++;
                if(tokens[this.index].token != "{")
                    throw new Exception("Style Error: " ~ tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                this.index ++;
                message.nStmt = this.ParseField();
                if(tokens[this.index].token == "}")
                {
                    this.index ++;
                    return message;
                }
                throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
            }
        case "extend":
            {
                Extend extend = new Extend;
                this.index ++;
                extend.name = tokens[this.index].token;
                extend.info = tokens[this.index].info;
                this.index ++;
                if(tokens[this.index].token != "{")
                    throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                this.index ++;
                extend.nStmt = this.ParseField();
                if(tokens[this.index].token == "}")
                {
                    this.index ++;
                    return extend;
                }
                
                else throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
            }
        case "package":
            {
                Package pack = new Package;
                this.index ++;
                pack.name = tokens[this.index].token;
                pack.info = tokens[this.index].info;
                this.index ++;
                if(tokens[this.index].token != ";")
                    throw new Exception("Style Error: expect \";\" " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                this.index ++;
                return pack;
            }
        case "option":
            {
                Options op = new Options;
                this.index ++;
                op.option_name = tokens[this.index].token;
                op.info = tokens[this.index].info;
                this.index ++;
                if(tokens[this.index].token != "=")
                    throw new Exception("Style Error: expect \"=\" " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                this.index ++;
                op.option_value = tokens[this.index].token;
                this.index ++;
                if(tokens[this.index].token != ";")
                    throw new Exception("Style Error: expect \";\" " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                this.index ++;
                return op;
            }
        case "import":
            {
                Dependency dp = new Dependency;
                this.index ++;
                dp.file = tokens[this.index].token;
                dp.info = tokens[this.index].info;
                this.index ++;
                if(tokens[this.index].token != ";")
                    throw new Exception("Style Error: expect \";\" " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                if(dp.file[0] != '\"'||dp.file[length -1] != '\"')
                    throw new Exception("Style Error: expect \" \" " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                this.index ++;
                return dp;
            }
        default:
            throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
        }
    }
    Stmt ParseField()
    {
        if (this.index == this.tokens.length)
        {
            throw new Exception("AST expected EOF in ParseField()");
        }
        switch(tokens[this.index].token)
        {
        case "optional":
        case "required":
        case "repeated":
            {
                Lable lable = new Lable;
                lable.type = tokens[this.index].token;
                lable.info = tokens[this.index].info;
                this.index ++;
                lable.nStmt = this.ParseVar();
                if((tokens[this.index].token == ";")&& (this.index < this.tokens.length))
                {
                    if(tokens[this.index +1].token != "}")
                    {
                        Sequence sequence = new Sequence;
                        sequence.First = lable;
                        this.index ++;
                        sequence.Second = this.ParseField();
                        return sequence;
                    }
                    else
                    {
                        this.index ++;
                        return lable;
                    }
                }
                else throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
            }
        case "message":
            {
                Message message = new Message;
                this.index ++;
                message.name = tokens[this.index].token;
                message.info =tokens[this.index].info;
                this.index ++;
                if(tokens[this.index].token != "{")
                    throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                this.index ++;
                message.nStmt = this.ParseField();
                if((tokens[this.index].token == "}")&& (this.index < this.tokens.length))
                {
                    if(tokens[this.index +1].token != "}")
                    {
                        Sequence sequence = new Sequence;
                        sequence.First = message;
                        this.index ++;
                        sequence.Second = this.ParseField();
                        return sequence;
                    }
                    this.index ++;
                    return message;
                }
                else throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
            }
        case "enum":
            {
                Enum enums = new Enum;
                this.index ++;
                enums.name = tokens[this.index].token;
                enums.info =tokens[this.index].info;
                this.index ++;
                if(tokens[this.index].token != "{")
                    throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                this.index ++;
                enums.nStmt = this.ParseEnum();
                if((tokens[this.index].token == "}")&& (this.index < this.tokens.length))
                {
                    if(tokens[this.index +1].token != "}")
                    {
                        Sequence sequence = new Sequence;
                        sequence.First = enums;
                        this.index ++;
                        sequence.Second = this.ParseField();
                        return sequence;
                    }
                    this.index ++;
                    return enums;
                }
                else throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
            }
        case "extend":
            {
                Extend extend = new Extend;
                this.index ++;
                extend.name = tokens[this.index].token;
                extend.info =tokens[this.index].info;
                this.index ++;
                if(tokens[this.index].token != "{")
                    throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                this.index ++;
                extend.nStmt = this.ParseField();
                if((tokens[this.index].token == "}")&& (this.index < this.tokens.length))
                {
                    if(tokens[this.index +1].token != "}")
                    {
                        Sequence sequence = new Sequence;
                        sequence.First = extend;
                        this.index ++;
                        sequence.Second = this.ParseField();
                        return sequence;
                    }
                    this.index ++;
                    return extend;                    
                }
                else throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
            }
        case "extensions":
            {
                Extensions extensions = new Extensions;
                this.index ++;
                extensions.start = tokens[this.index].token;
                extensions.info = tokens[this.index].info;
                this.index ++;
                if(tokens[this.index].token != "to")
                    throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                this.index ++;
                extensions.end = tokens[this.index].token;
                this.index ++;
                if((tokens[this.index].token == ";")&& (this.index < this.tokens.length))
                {
                    if(tokens[this.index +1].token != "}")
                    {
                        Sequence sequence = new Sequence;
                        sequence.First = extensions;
                        this.index ++;
                        sequence.Second = this.ParseField();
                        return sequence;
                    }
                    this.index ++;
                    return extensions;
                }
                else throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
            }
        default:
            throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
        }
    }
    Stmt ParseVar()
    {
        if (this.index == this.tokens.length)
        {
            throw new Exception("AST expected EOF in ParserVar()");
        }
        VarType vartype = new VarType;
        vartype.type = tokens[this.index].token;
        vartype.info = tokens[this.index].info;
        this.index ++;
        vartype.nStmt = this.ParsePos();
        return vartype;
    }
    Stmt ParsePos()
    {
        if (this.index == this.tokens.length)
        {
            throw new Exception("AST expected EOF in ParsePos()");
        }
        VarPostion postion = new VarPostion;
        postion.name = tokens[this.index].token;
        postion.info =tokens[this.index].info;
        this.index ++;
        if(tokens[this.index].token != "=")
            throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
        this.index ++;
        for(int i = 0; i < tokens[this.index].token.length; i++)
        {
            if(!isdigit(tokens[this.index].token[i]))
                throw new Exception("Style Error: it should be a int number " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
        }
        postion.pos = tokens[this.index].token;
        if(tokens[this.index+1].token == ";")
        {
            this.index ++;
            return postion;
        }
        this.index ++;
        if(tokens[this.index].token == "[")
        {
            Sequence sequence = new Sequence;
            sequence.First = postion;
            this.index ++;
            sequence.Second = this.ParseAddtion();
            if(tokens[this.index].token == ";")
                return sequence;
            throw new Exception("Style Error: it expect \";\" " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
        }
        else
            throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
    }
    Stmt ParseAddtion()
    {
        if (this.index == this.tokens.length)
        {
            throw new Exception("AST expected EOF in ParseAddtion()");
        }
        switch(tokens[this.index].token)
        {
        case "default":
        case "packed":
        case "deprecated":
            {
                FieldAddtion field_addtion = new FieldAddtion;
                field_addtion.type = tokens[this.index].token;
                this.index ++;
                if(tokens[this.index].token != "=")
                    throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
                this.index ++;
                field_addtion.value = tokens[this.index].token;
                this.index ++;
                if(tokens[this.index].token == "]")
                {
                    this.index ++;
                    return field_addtion;
                }
                throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
            }
        default:
            throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
        }
    }
    Stmt ParseEnum()
    {
        if (this.index == this.tokens.length)
        {
            throw new Exception("AST expected EOF in ParseEnum()");
        }
        EnumValue enum_value = new EnumValue;
        enum_value.key = tokens[this.index].token;
        enum_value.info = tokens[this.index].info;
        this.index ++;
        if(tokens[this.index].token != "=")
            throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
        this.index ++;
        enum_value.value = tokens[this.index].token;
        this.index ++;
        if((tokens[this.index].token == ";") && (this.index < this.tokens.length))
        {
            if(tokens[this.index +1].token != "}")
            {
                Sequence sequence = new Sequence;
                sequence.First = enum_value;
                this.index ++;
                sequence.Second = this.ParseEnum();
                return sequence;
            }
            this.index ++;
            return enum_value;
        }
        else throw new Exception("Style Error: " ~  tokens[this.index].info ~ ": " ~ tokens[this.index].token);
    }
}
class Stmt
{
    string info;
}
class Dependency : Stmt
{
    string file;
}
class Package : Stmt
{
    string name;
}
class Options :Stmt
{
    string option_name;
    string option_value;
}
class Message : Stmt
{
    string name;
    Stmt nStmt;
}
class Extend : Stmt
{
    string name;
    Stmt nStmt;
}
class Lable : Stmt
{
    string type;
    Stmt nStmt;
}
class VarType : Stmt
{
    string type;
    Stmt nStmt;
}
class VarPostion : Stmt
{
    string name;
    string pos;
    Stmt nStmt;
}
class FieldAddtion : Stmt
{
    string type;
    string value;
}
class Enum : Stmt
{
    string name;
    Stmt nStmt;
}
class EnumValue : Stmt
{
    string key;
    string value;
}
class Sequence : Stmt
{
    Stmt First;
    Stmt Second;
}
class Pack : Stmt
{
    bool pack_stat;
    Stmt nStmt;
}
class Extensions : Stmt
{
    string start;
    string end;
}
