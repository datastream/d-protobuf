module writer;

private import tango.io.device.File;
private import tango.io.stream.Lines;
private import tango.text.Util;

private import tango.stdc.ctype;

private alias char[] string;

class Format
{
    File file;
    uint not_n;
    this(char[] name)
    {
        file = new File(getfilename(name), File.WriteCreate);
        not_n = 0;
    }
    char[] getfilename(char[] name)
    {
        int pos = 0;
        for(int i =0; i < name.length; i++)
        {
            if(name[i] == '.')
                pos = i;
        }
        if (pos == 0)
            pos = name.length;
        if (pos < name.length) 
            if (name[pos+1] == '/')
                pos = name.length;
        return name[0..pos] ~ ".d";
    }
    void FormatWriteToFile(string input)
    {
        string rst;
        int tab;
        tab = 0;
        for(int i = 0 ; i < input.length ; i++)
        {
            switch(input[i])
            {
            case '{':
                rst ~= "\n"~ addTab(tab) ;
                tab ++;
                rst ~= "{\n"~addTab(tab);
                break;
            case '}':
                tab --;
                if(input[i-1] =='}')
                {
                    rst ~="}\n";
                }
                else
                    if(i !=(input.length -1)&&input[i+1]!= '}')
                        rst ~= "\n"~ addTab(tab) ~"}\n"~addTab(tab);
                    else
                        rst ~= "\n"~ addTab(tab) ~"}\n"~addTab(tab-1);
                break;
            case ';':
                if(not_n > 0)
                {
                    rst ~=";";
                }
                else
                {
                    if(i != (input.length -1))
                        if(input[i+1] == '}')
                            rst ~= ";";
                        else
                            rst ~= ";\n"~addTab(tab);
                }
                break;
            case '(':
                not_n++;
                rst ~= '(';
                break;
            case ')':
                if((input[i -1] == '(')||(input[i -1] == ')'))
                    rst ~= ")";
                else
                    rst ~= " )";
                if(input[i+1] == '\n')
                {
                    i++;
                    rst ~= "\n"~addTab(tab+1);
                }
                not_n --;
                break;
            case ',':
                if((input[i+1] != ' ')||(i != (input.length -1)))
                    rst ~= ", ";
                else
                    rst ~= ",";
                break;
            case '=':
                if(isalnum(input[i-1]))
                    rst ~= " = ";
                else
                    rst ~= "=";
                break;
            default:
                rst ~= input[i];
                break;
            }
        }
        file.write(rst);
        file.close();
    }
    string addTab(int tabs)
    {
        string rst;
        for(int i = 0 ; i < tabs ; i++)
        {
            rst ~= "\t";
        }
        return rst;
    }
}
