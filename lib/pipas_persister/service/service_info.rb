module PipasPersister
  module Service
    class ServiceInfo < Base

      get '/planning' do
        tuple = tuple_extract{ scheduling.identity }

        # Set the HTTP ETag
        etag compute_etag(tuple.problem_key, tuple.last_modified, tuple.last_scheduled)

        # Set the Last-Modified header
        last_modified max(tuple.last_modified, tuple.last_scheduled)

        # Set must-revalidate to Cache-Control
        cache_control :public, :must_revalidate

        # Return the current scheduling problem
        respond_with tuple_extract{
          service.planning
        }
      end

      get '/availabilities' do
        respond_with relvar{
          beds    = rename(base.bed_availabilities, quantity: :beds)
          nurses  = rename(base.nurse_availabilities, quantity: :nurses)
          minutes = rename(base.minutes_per_day, quantity: :minutes)
          avail   = join(join(beds, nurses), minutes)
          allbut(extend(avail, open: ->(t){ t.minutes > 0 }), :minutes)
        }
      end

    private

      def max(t1, t2)
        t1 > t2 ? t1 : t2
      end

    end # class ServiceInfo
  end # module Service
end # module PipasPersister
