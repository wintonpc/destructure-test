request = {
  sample_path: 'smb://server/path/to/file',
  customer: 'veridian',
  batch_id: '5256ecd45d29b290a1000001',
  batch_type: 'production',
  unique_sample_id: '5'
}

success_response = {
    succeeded: true,
    request: request
}

failure_response = {
    succeeded: false,
    error_message: 'file not found',
    hostname: 'server001.indigobio.com',
    request: request
}

def handle_response(response)
  case
    when response =~ { success: true, request: { customer: customer, batch_id: batch_id }}
      quantitate_batch_if_converted(batch_id, customer)
    when response =~ { success: false, error_message: msg, hostname: server, request: { sample_path: sample_path } }
      handle_failed_conversion(msg, server, sample_path)
  end
end


# without pattern matching:

def handle_response(response)
  if response.success
    handle_success(response[:request])
  else
    handle_failure(response[:error_message], response[:hostname], response[:request])
  end
end

def handle_success(request)
  quantitate_batch_if_converted(request[:customer], request[:batch_id])
end

def handle_failure(msg, server, request)
  handle_failed_conversion(msg, server, request[:sample_path])
end
