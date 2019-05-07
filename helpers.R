player_to_zero = function(x, y){
  ifelse(y==0, 0, x)
}

quicknorm = function(values){
    normalized = (values - min(values, na.rm = T)) / (max(values, na.rm = T) - min(values, na.rm = T))
    return(normalized)
}

quickdenorm = function(value, min, max){
  denormalized = (value * (max - min) + min);
  return (denormalized)
}