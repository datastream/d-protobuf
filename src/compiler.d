private import tango.io.Stdout;
private import tango.io.device.File;
private import tango.util.log.Log;
private import tango.util.log.Config;

import preprocessor;
import codegen;
import analysis;

void main(char[][] args)
{
    if(args.length <2)
    {
        Stdout("no input files").newline;
        return ;
    }
    auto logger = Log.lookup("protobuf");
    try 
    {
        PreProcessor a = new PreProcessor(args[1]);
        a.Scan();
        //for(int i =0; i < a.tokens.length ; i++)
        //{
        //    writefln(a.tokens[i].info ~": "~a.tokens[i].token);
        //}
        Analysis anl = new Analysis(a.tokens,args[1]);
        CodeGen dcode = new CodeGen(anl.filedescriptor);
    }
    catch(Exception x)
    {
        logger.error ("Exception: " ~ x.toString);
    }
}

