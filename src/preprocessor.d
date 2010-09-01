module preprocessor;

private import tango.io.device.File;
private import tango.io.stream.Lines;
private import tango.stdc.ctype;

import prototype;


class PreProcessor
{
    char[] context;
    wordmap[] tokens;
    this(char[] name)
    {
        File file = new File(name);
        string tmp;
        foreach(line; new Lines!(char)(file))
        {
            if(line.length > 1)
                if(line[0 .. 2] == "//")
                {
                    continue;
                }
            this.context ~= line ~ "\n";
        }
        file.close;
    }
    void Scan()
    {
        char[][] rst;
        rst.length = 1;
        int line;
        int postion;
        for(int i = 0; i < this.context.length;++i)
        {
            if(this.context[i] == '\n')
            {
                line ++;
                postion = 0;
            }
            if(isspace(this.context[i]))
                if(rst[rst.length -1])
                {
                    rst.length = rst.length + 1;
                    wordmap tmp;
                    tmp.token = rst[length-2];
                    tmp.info = tango.text.convert.Integer.toString(line) ~ ": " ~ tango.text.convert.Integer.toString(postion);
                    tokens ~= tmp;
                }
            switch(this.context[i])
            {
            case '{':
            case '}':
            case ';':
            case '[':
            case ']':
            case '=':
                if(rst[rst.length -1] is null)
                {
                    rst[rst.length -1] ~= context[i];
                    rst.length = rst.length + 1;
                    wordmap tmp;
                    tmp.token = rst[length-2];
                    tmp.info = tango.text.convert.Integer.toString(line) ~ ": " ~ tango.text.convert.Integer.toString(postion);
                    tokens ~= tmp;
                }
                else
                {
                    wordmap tmp;
                    tmp.token = rst[length-1];
                    tmp.info = tango.text.convert.Integer.toString(line) ~ ": " ~ tango.text.convert.Integer.toString(postion);
                    tokens ~= tmp;
                    rst.length = rst.length + 1;
                    rst[rst.length -1] ~= context[i];
                    rst.length = rst.length + 1;
                    tmp.token = rst[length-2];
                    tmp.info = tango.text.convert.Integer.toString(line) ~ ": " ~ tango.text.convert.Integer.toString(postion);
                    tokens ~= tmp;
                }
                break;
            default:
                if(!isspace(context[i]))
                {
                    rst[rst.length -1] ~= context[i];
                }
            }
            postion ++;
        }
        if(rst[rst.length -1] is null)
            rst.length = rst.length - 1;
    }
}
