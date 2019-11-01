function b = isidentity(T)

b = all(all(eye(length(T))==T));

