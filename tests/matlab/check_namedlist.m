% OBJ-2: NamedList indexing.
x = snakemake_matlab.NamedList({'a.txt', 'b.txt'}, {'raw', ''});
assert(strcmp(x{1}, 'a.txt'));
assert(strcmp(x.raw, 'a.txt'));
assert(strcmp(x{end}, 'b.txt'));
assert(length(x) == 2);
assert(isequal(fieldnames(x), {'raw'}));
c = cell(x);
assert(strcmp(c{2}, 'b.txt'));
assert(strcmp(x.raw(1:3), 'a.t'));
