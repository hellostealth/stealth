module Stealth
  module FlowTriggers
    def trigger_flow(flow_name, state_name)
      # Ensure that service_event is fetched from the controller's context
      service_event = self.try(:service_event)
      FlowManager.trigger_flow(flow_name, state_name, service_event)
    end

    def flow(flow_name, &block)
      FlowManager.flow(flow_name, &block)
    end
  end
end
