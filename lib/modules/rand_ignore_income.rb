# Returns a true or false by a fraction passed

def rand_ignore(p, q)
  # $param p: true
  # $param q: false
  p=1 unless p
  q=1 unless q
  rnd = [true] * p + [false] * q
  rnd.sample
end
