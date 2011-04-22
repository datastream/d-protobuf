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
          rst ~= addTab(tab) ~ "{\n";
          tab ++;
          break;
        case '}':
          tab --;
          rst ~= addTab(tab) ~"}\n";
          break;
        case ';':
          if(i != (input.length -1)&&(not_n == 0)) {
            rst ~= ";\n";
          } else {
            rst ~= ";";
          }
          break;
        case '(':
          rst ~= '(';
          not_n ++;
          break;
        case ')':
          rst ~= ")";
          not_n --;
          while(true)
          {
            i++;
            if(input[i] == ' ')
              continue;
            if(input[i] == '{')
              rst ~= "\n";
            i--;
            break;
          }
          break;
        case ',':
          if((i != (input.length -1))) {
            rst ~= ", ";
          } else {
            rst ~= ",";
          }
          break;
        case '=':
          if(isalnum(input[i-1])) {
            rst ~= " =";
          } else if(isalnum(input[i+1])) {
            rst ~= "= ";
          } else {
            rst ~= "=";
          }
          break;
        case ' ':
          if((input[i -1] != '{')||(input[i - 1] != '}')) {
            rst ~= " ";
          }
          while(true)
          {
            i++;
            if(input[i] == ' ')
              continue;
            i--;
            break;
          }
          break;
        default:
          if(i!= 0) {
            if((input[i-1] == ' ')&&(input[i] == ' '))
              break;
            if((input[i-1] == ';')||(input[i-1] == '}')||(input[i-1] == '{')) {
              rst ~= addTab(tab) ~ input[i];
            } else {
              rst ~= input[i];
            }
            if(i != (input.length -1))
            {
              if(input[i+1] == '{')
                rst ~= "\n";
            }
          } else {
            rst ~= input[i];
          }
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
