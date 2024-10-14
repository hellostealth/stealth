module Stealth
  module FlowTriggers
    def trigger_flow(flow_name, state_name, service_event)
      FlowManager.trigger_flow(flow_name, state_name, service_event)
    end

    def flow(flow_name, &block)
      FlowManager.flow(flow_name, &block)
    end
  end
end
