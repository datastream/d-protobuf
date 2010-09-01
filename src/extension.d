template Ext()
{
    void SetExtension(ref ExtensionIdentifier!(uint,uint) tp,uint value)
    {
        tp.value_ = value;
        _unknown_fields ~= toVarint(value,tp.number_,tp.type_);
    }
    void SetExtension(ref ExtensionIdentifier!(uint[],uint) tp,uint[] value)
    {
        tp.value_ = value;
        if(tp.packed_)
        {
            _unknown_fields ~= toPackVarint(value,tp.number_,tp.type_);
            return;
        }
        for(int i =0 ; i< value.length; i++)
        {
            _unknown_fields ~= toVarint(value[i],tp.number_,tp.type_);
        }
    }
    void SetExtension(ref ExtensionIdentifier!(int,int) tp,int value)
    {
        tp.value_ = value;
        _unknown_fields ~= toVarint(value,tp.number_,tp.type_);
    }
    void SetExtension(ref ExtensionIdentifier!(int[],int) tp,int[] value)
    {
        tp.value_ = value;
        if(tp.packed_)
        {
            _unknown_fields ~= toPackVarint(value,tp.number_,tp.type_);
            return;
        }
        for(int i =0 ; i< value.length; i++)
        {
            _unknown_fields ~= toVarint(value[i],tp.number_,tp.type_);
        }
    }
    void SetExtension(ref ExtensionIdentifier!(ulong,ulong) tp,ulong value)
    {
        tp.value_ = value;
        _unknown_fields ~= toVarint(value,tp.number_,tp.type_);
    }
    void SetExtension(ref ExtensionIdentifier!(ulong[],ulong) tp,ulong[] value)
    {
        tp.value_ = value;
        if(tp.packed_)
        {
            _unknown_fields ~= toPackVarint(value,tp.number_,tp.type_);
            return;
        }
        for(int i =0 ; i< value.length; i++)
        {
            _unknown_fields ~= toVarint(value[i],tp.number_,tp.type_);
        }
    }
    void SetExtension(ref ExtensionIdentifier!(long,long) tp,long value)
    {
        tp.value_ = value;
        _unknown_fields ~= toVarint(value,tp.number_,tp.type_);
    }
    void SetExtension(ref ExtensionIdentifier!(long[],long) tp,long[] value)
    {
        tp.value_ = value;
        if(tp.packed_)
        {
            _unknown_fields ~= toPackVarint(value,tp.number_,tp.type_);
            return;
        }
        for(int i =0 ; i< value.length; i++)
        {
            _unknown_fields ~= toVarint(value[i],tp.number_,tp.type_);
        }
    }
    void SetExtension(ref ExtensionIdentifier!(double,double) tp,double value)
    {
        tp.value_ = value;
        _unknown_fields ~= toVarint(value,tp.number_,tp.type_);
    }
    void SetExtension(ref ExtensionIdentifier!(double[],double) tp,double[] value)
    {
        tp.value_ = value;
        if(tp.packed_)
        {
            _unknown_fields ~= toPackVarint(value,tp.number_,tp.type_);
            return;
        }
        for(int i =0 ; i< value.length; i++)
        {
            _unknown_fields ~= toVarint(value[i],tp.number_,tp.type_);
        }
    }
    void SetExtension(ref ExtensionIdentifier!(float,float) tp,float value)
    {
        tp.value_ = value;
        _unknown_fields ~= toVarint(value,tp.number_,tp.type_);
    }
    void SetExtension(ref ExtensionIdentifier!(float[],float) tp,float[] value)
    {
        tp.value_ = value;
        if(tp.packed_)
        {
            _unknown_fields ~= toPackVarint(value,tp.number_,tp.type_);
            return;
        }
        for(int i =0 ; i< value.length; i++)
        {
            _unknown_fields ~= toVarint(value[i],tp.number_,tp.type_);
        }
    }
    void SetExtension(ref ExtensionIdentifier!(bool,bool) tp,bool value)
    {
        tp.value_ = value;
        _unknown_fields ~= toVarint(cast(uint)(value?1:0),tp.number_,tp.type_);
    }
    void SetExtension(ref ExtensionIdentifier!(bool[],bool) tp,bool[] value)
    {
        tp.value_ = value;
        if(tp.packed_)
        {
            _unknown_fields ~= toPackVarint(value,tp.number_,tp.type_);
            return;
        }
        for(int i =0 ; i< value.length; i++)
        {
            _unknown_fields ~= toVarint(value[i],tp.number_,tp.type_);
        }
    }
    void SetExtension(ref ExtensionIdentifier!(string,string) tp,string value)
    {
        tp.value_ = value;
        _unknown_fields ~= toByteString(value,tp.number_,tp.type_);
    }
    void SetExtension(ref ExtensionIdentifier!(string[],string) tp,string[] value)
    {
        tp.value_ = value;
        if(tp.packed_)
        {
            _unknown_fields ~= toPackByteString(value,tp.number_,tp.type_);
            return;
        }
        for(int i =0 ; i< value.length; i++)
        {
            _unknown_fields ~= toByteString(value[i],tp.number_,tp.type_);
        }
    }
    void SetExtension(ref ExtensionIdentifier!(byte[],byte) tp,byte[] value)
    {
        tp.value_ = value;
        _unknown_fields ~= toByteString(value,tp.number_,tp.type_);
    }
    void SetExtension(ref ExtensionIdentifier!(byte[][],byte) tp,byte[][] value)
    {
        tp.value_ = value;
        if(tp.packed_)
        {
            _unknown_fields ~= toPackByteString(value,tp.number_,tp.type_);
            return;
        }
        for(int i =0 ; i< value.length; i++)
        {
            _unknown_fields ~= toByteString(value[i],tp.number_,tp.type_);
        }
    }
    void SetExtension(ref ExtensionIdentifier!(Message,Message) tp,Message value)
    {
        tp.value_ = value;
        _unknown_fields ~= toByteString(value.Serialize(),tp.number_,tp.type_);
    }
    void SetExtension(ref ExtensionIdentifier!(Message[],Message) tp,Message[] value)
    {
        tp.value_ = value;
        if(tp.packed_)
        {
            byte[] rst;
            _unknown_fields ~= toPackByteString(value,tp.number_,tp.type_);
            return;
        }
        for(int i =0 ; i< value.length; i++)
        {
            _unknown_fields ~= toByteString(value[i].Serialize(),tp.number_,tp.type_);
        }
    }

    void GetExtension(ref ExtensionIdentifier!(uint,uint) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_ENUM:
                case Type.TYPE_UINT32:
                    {
                        tp.value_ = Decode!(uint)(input);
                        break;
                    }
                case Type.TYPE_FIXED32:
                    {
                        tp.value_ = fromFixed!(uint)(rst);
                        break;
                    }
                }
            }
        }
    }
    void GetExtension(ref ExtensionIdentifier!(uint[],uint) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_ENUM:
                case Type.TYPE_UINT32:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= Decode!(uint)(input);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= Decode!(uint)(input);
                        break;
                    }
                case Type.TYPE_FIXED32:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= fromFixed!(uint)(rst);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= fromFixed!(uint)(rst);
                        break;
                    }
                }
            }
        }
    }

    void GetExtension(ref ExtensionIdentifier!(int,int) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_INT32:
                    {
                        tp.value_ = cast(int)Decode!(uint)(input);
                        break;
                    }
                case Type.TYPE_SINT32:
                    {
                        tp.value_ = ZigZagDecode32(Decode!(uint)(input));
                        break;
                    }
                case Type.TYPE_SFIXED32:
                    {
                        tp.value_ = fromFixed!(int)(rst);
                        break;
                    }
                }
            }
        }
    }
    void GetExtension(ref ExtensionIdentifier!(int[],int) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_INT32:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= cast(int)Decode!(uint)(input);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= cast(int)Decode!(uint)(input);
                        break;
                    }
                case Type.TYPE_SINT32:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= ZigZagDecode32(Decode!(uint)(input));
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= ZigZagDecode32(Decode!(uint)(input));
                        break;
                    }
                case Type.TYPE_SFIXED32:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= fromFixed!(int)(rst);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= fromFixed!(int)(rst);
                        break;
                    }
                }
            }
        }
    }

    void GetExtension(ref ExtensionIdentifier!(bool,bool) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_BOOL:
                    {
                        tp.value_ = ((Decode!(uint)(rst)== 1)?true:false);
                        break;
                    }
                }
            }
        }
    }
    void GetExtension(ref ExtensionIdentifier!(bool[],bool) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_BOOL:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= ((Decode!(uint)(rst)== 1)?true:false);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= ((Decode!(uint)(rst)== 1)?true:false);
                        break;
                    }
                }
            }
        }
    }

    void GetExtension(ref ExtensionIdentifier!(ulong,ulong) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_UINT64:
                    {
                        tp.value_ = Decode!(ulong)(input);
                        break;
                    }
                case Type.TYPE_FIXED64:
                    {
                        tp.value_ = fromFixed!(ulong)(rst);
                        break;
                    }
                }
            }
        }
    }
    void GetExtension(ref ExtensionIdentifier!(ulong[],ulong) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_UINT64:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= Decode!(ulong)(input);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= Decode!(ulong)(input);
                        break;
                    }
                case Type.TYPE_FIXED64:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= fromFixed!(ulong)(rst);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= fromFixed!(ulong)(rst);
                        break;
                    }
                }
            }
        }
    }


    void GetExtension(ref ExtensionIdentifier!(long,long) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_INT64:
                    {
                        tp.value_ = cast(long)Decode!(ulong)(input);
                        break;
                    }
                case Type.TYPE_SINT64:
                    {
                        tp.value_ = ZigZagDecode64(Decode!(ulong)(input));
                        break;
                    }
                case Type.TYPE_SFIXED64:
                    {
                        tp.value_ = fromFixed!(long)(rst);
                        break;
                    }
                }
            }
        }
    }
    void GetExtension(ref ExtensionIdentifier!(long[],long) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_INT64:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= cast(long)Decode!(ulong)(input);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= cast(long)Decode!(ulong)(input);
                        break;
                    }
                case Type.TYPE_SINT64:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= ZigZagDecode64(Decode!(ulong)(input));
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= ZigZagDecode64(Decode!(ulong)(input));
                        break;
                    }
                case Type.TYPE_SFIXED64:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= fromFixed!(long)(rst);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= fromFixed!(long)(rst);
                        break;
                    }
                }
            }
        }
    }

    void GetExtension(ref ExtensionIdentifier!(double,double) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_DOUBLE:
                    {
                        tp.value_ = fromFixed!(double)(rst);
                        break;
                    }
                }
            }
        }
    }
    void GetExtension(ref ExtensionIdentifier!(double[],double) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_DOUBLE:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= fromFixed!(double)(rst);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= fromFixed!(double)(rst);
                        break;
                    }
                }
            }
        }
    }

    void GetExtension(ref ExtensionIdentifier!(float,float) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_FLOAT:
                    {
                        tp.value_ = fromFixed!(float)(rst);
                        break;
                    }
                }
            }
        }
    }
    void GetExtension(ref ExtensionIdentifier!(float[],float) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_FLOAT:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= fromFixed!(float)(rst);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= fromFixed!(float)(rst);
                        break;
                    }
                }
            }
        }
    }

    void GetExtension(ref ExtensionIdentifier!(string,string) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_STRING:
                    {
                        tp.value_ = cast(string)rst;
                        break;
                    }
                }
            }
        }
    }
    void GetExtension(ref ExtensionIdentifier!(string[],string) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_STRING:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= cast(string)rst;
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= cast(string)rst;
                        break;
                    }
                }
            }
        }
    }

    void GetExtension(ref ExtensionIdentifier!(byte[],byte) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_BYTES:
                    {
                        tp.value_ = rst;
                        break;
                    }
                }
            }
        }
    }
    void GetExtension(ref ExtensionIdentifier!(byte[][],byte) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_BYTES:
                    {
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= rst;
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= rst;
                        break;
                    }
                }
            }
        }
    }

    void GetExtension(ref ExtensionIdentifier!(Message,Message) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_MESSAGE:
                    {
                        tp.v_type_ = new typeof(tp.tupleof[length -1]);
                        tp.value_= tp.v_type_.Deserialize(rst);
                        break;
                    }
                }
            }
        }
    }
    void GetExtension(ref ExtensionIdentifier!(Message[],Message) tp)
    {
        byte[] input = _unknown_fields.dup;
        while(input.length >0)
        {
            uint tag = GetTag(input);
            if(tag == MakeTag(tp.number_,WireTypeForFieldType[tp.type_]))
            {
                byte[] rst = GetFieldValue(input,tag);
                switch(tp.type_)
                {
                case Type.TYPE_MESSAGE:
                    {
                        tp.v_type_ = new typeof(tp.tupleof[length -1]);
                        if(tp.packed_)
                        {
                            int len = Decode!(uint)(input);
                            byte[] tmp= input[0..len];
                            input = input[len..length];
                            while(rst.length >0)
                            {
                                rst = GetFieldValue(tmp,tag);
                                tp.value_ ~= tp.v_type_.Deserialize(rst);
                            }
                            return;
                        }
                        if(tp.repeated_)
                            tp.value_ ~= tp.v_type_.Deserialize(rst);
                        break;
                    }
                }
            }
        }
    }
}
