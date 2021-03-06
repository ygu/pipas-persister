module PipasPersister
  module Viewpoint
    module Scheduling
      include Alf::Viewpoint

      SERVICE_SOLUTION = {
        "nurse_load" => 0.0,
        "bed_load"   => 0.0
      }

      depends :base, Base

    ### schedule (facade)

      def identity
        base.scheduling
      end

      def problems
        extend(base.scheduling,
          current_time: PipasPersister::getSimulationTime,
          service:    ->(t){ service.to_relation.tuple_extract },
          treatments: ->(t){ problem_treatments })
      end

      def solutions
        extend(base.scheduling,
          service: SERVICE_SOLUTION,
          treatments: ->(t){ solution_treatments })
      end

    ### about service

      def service
        extend(Relation::DEE,
          bed_availabilities:   ->(t){ base.bed_availabilities   },
          nurse_availabilities: ->(t){ base.nurse_availabilities },
          minutes_per_day:      ->(t){ base.minutes_per_day },
          treatment_plans:      ->(t){ treatment_plans })
      end

    ### about treatments

      def solution_treatments
        treatments = project(base.treatments, [:treatment_id])
        treatments = image(treatments,
          allbut(base.appointments, [:appointment_id, :fixed]),
          :appointments)
        treatments
      end

      def problem_treatments
        unavailabilities = project(base.patient_unavailabilities, [:treatment_id, :unavailable_at])
        treatments = allbut(base.treatments, [:patient_id])
        treatments = image(treatments, allbut(appointments, [:appointment_id]), :appointments)
        treatments = image(treatments, unavailabilities, :unavailabilities)
        treatments
      end

      def appointments
        aps = base.appointments
        aps = image(aps, base.treatment_doses, :doses)
        extend(aps,
          doses: ->(t){ t.doses.to_hash(:kind => :dose) })
      end

    ### about treatment plans

      def treatment_plans
        plans = project(base.treatment_plans, [:tplan_id])
        plans = image(plans, base.treatment_plan_steps, :steps)
        plans = join(plans, base.treatment_plan_derived_attrs)
        plans
      end

    end # module Scheduling
  end # module Viewpoint
end # module PipasPersister
