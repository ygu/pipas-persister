module PipasPersister
  module Service
    class Scheduling < Base

      get '/problem' do
        tuple = tuple_extract{ scheduling.identity }

        # Set the HTTP ETag
        etag compute_etag(tuple.problem_key, tuple.last_modified)

        # Set the Last-Modified header
        last_modified tuple.last_modified

        # Set must-revalidate to Cache-Control
        cache_control :public, :must_revalidate

        # Return the current scheduling problem
        respond_with tuple_extract{
          scheduling.problems
        }
      end

      get '/solution' do
        tuple = tuple_extract{ scheduling.identity }

        # Set the HTTP ETag
        etag compute_etag(tuple.problem_key, tuple.last_modified)

        # Set the Last-Modified header
        last_modified tuple.last_modified

        # Set must-revalidate to Cache-Control
        cache_control :public, :must_revalidate

        # Return the current scheduling problem
        respond_with tuple_extract{
          scheduling.solutions
        }
      end

      put '/solution' do
        tuple = tuple_extract{ scheduling.identity }

        # Set the HTTP ETag
        etag compute_etag(tuple.problem_key, tuple.last_modified)

        input = request.body.read
        input = ::JSON.load(input)
        r = Resource['/scheduling/solution'].decode(input)
        run_operation Operation::UpdateSchedulingSolution, r
        200
      end

    end # class Scheduling
  end # module Service
end # module PipasPersister
