def qsort(array)
  case
    when array =~ []
      []
    when array =~ [ pivot, *rest ]
      qsort(rest.select{|x| x < pivot}) + [pivot] + qsort(rest.select{|x| x >= pivot})
  end
end
