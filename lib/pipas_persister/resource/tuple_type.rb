module PipasPersister
  class Resource
    class TupleType < Type
      include HashBasedType

      def decode(arg, location = nil)
        ruby_type.new(decode_hash(arg, location))
      end

      def ruby_type
        @ruby_type ||= Tuple[Hash[coercers.map{|k,(_,v)| [k, v.ruby_type] }]]
      end

    end # class TupleType
  end # class Resource
end # module PipasPersister
