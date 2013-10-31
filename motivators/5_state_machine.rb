class InstrumentStateMachine

  def initialize(instrument_gateway, ascent_gateway)
    @instrument_gateway = instrument_gateway
    @ascent_gateway = ascent_gateway
    listen_for_instrument_events(@instrument_gateway)
    listen_for_ascent_events(@ascent_gateway)
    disconnected
  end

  def disconnected
    receive do |event|
      case
        # events from instrument gateway
        when event =~ :connection_established
          @ascent_gateway.notify_instrument_connected
          idle
      end
    end
  end

  def idle
    receive do |event|
      case
        # events from instrument gateway
        when event =~ BatchStarted[batch_name, num_samples]
          @ascent_gateway.batch_started(batch_name, num_samples)
          running
        when event =~ :connection_lost
          @ascent_gateway.notify_instrument_disconnected
          disconnected
      end
    end
  end

  def running
    receive do |event|
      case
        # events from instrument gateway
        when event =~ SampleData[id, data]
          @ascent_gateway.sample_data(id, data)
        when event =~ BatchCompleted[batch_name]
          @ascent_gateway.batch_completed(batch_name)
        # events from ascent
        when event =~ { request: 'reinject', sample_id: id }
          @instrument_gateway.request_reinject(id)
        when event =~ { request: 'abort batch', batch_name: name}
          @instrument_gateway.abort_batch(name)
          aborting
      end
    end
  end

  def aborting
    set_timeout(30)
    receive do |event|
      case
        # events from instrument gateway
        when event =~ BatchAborted[batch_name]
          @ascent_gateway.batch_aborted_successfully(batch_name)
          idle
        # events from state machine
        when event =~ :timed_out
          @ascent_gateway.aborting_timed_out(batch_name)
          aborting
      end
    end
  end

end