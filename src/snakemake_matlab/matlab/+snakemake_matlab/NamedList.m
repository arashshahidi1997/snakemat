classdef NamedList
    % Values reachable by position (x{i}) and, if named, by name (x.name),
    % like Snakemake's Namedlist.

    properties (Access = private)
        values
        names
    end

    methods

        function obj = NamedList(values, names)
            obj.values = values;
            obj.names = names;
        end

        function varargout = subsref(obj, s)
            switch s(1).type
                case '{}'
                    out = obj.values{s(1).subs{:}};
                case '.'
                    k = find(strcmp(obj.names, s(1).subs), 1);
                    if isempty(k)
                        out = builtin('subsref', obj, s(1));
                    else
                        out = obj.values{k};
                    end
                otherwise
                    out = builtin('subsref', obj, s(1));
            end
            if numel(s) > 1
                out = subsref(out, s(2:end));
            end
            varargout = {out};
        end

        function n = numArgumentsFromSubscript(~, ~, ~)
            n = 1;
        end

        function e = end(obj, ~, ~)
            e = numel(obj.values);
        end

        function n = length(obj)
            n = numel(obj.values);
        end

        function c = cell(obj)
            c = obj.values;
        end

        function f = fieldnames(obj)
            f = obj.names(~cellfun(@isempty, obj.names));
            f = f(:);
        end

    end
end
