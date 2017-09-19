# This is the basic set of functions for calculating feature distance
# between words.
# better documentation pending

Array_Or_String = Union{SubString{String}, String}
Char_Or_String = Union{String, Char}

# compares two segments
# sub_penalty is the penalty for substitution
# ins_penalty is the penalty for insertion
# 'average' distance not yet implemented
function compare_segments(segment1::Array_Or_String, segment2::Array_Or_String,
                          underspec_cost::Float64 = 0.25,
                          sub_penalty::Float64 = 1.0,
                          ins_del_basis::String = "empty",
                          ins_penalty::Float64 = 1.0)

    # checks whether two features are different
    # if two features are equal, returns 0
    # if one of them is underspecified '0' returns underspec_cost
    # otherwise return 1 (max cost)
    function check_feature_difference(val1::Char_Or_String, val2::Char_Or_String,
                                      underspec_cost::Float64)
        if (val1 == val2)
            return 0
        elseif ((val1 == "0") | (val2 == "0"))
            return (underspec_cost)
        else
            return (1)
        end
    end

    # we compare segment1 to segment2
    if segment1 == "empty"
        if ins_del_basis == "empty"
            distance = (sum([check_feature_difference("0", sign, underspec_cost) for sign in segment2]))
        elseif (ins_del_basis == "average")
            distance = ins_del_difference
        end
        return (distance * ins_penalty)

    elseif (segment2 == "empty")
        if (ins_del_basis == "empty")
            distance = (sum([check_feature_difference(sign,"0", underspec_cost) for sign in segment1]))
        elseif (selfins_del_basis == "average")
            distance = ins_del_difference
        end
        return (distance * ins_penalty)
    end

    return (sum([check_feature_difference(segment1[k], segment2[k], underspec_cost) for
                 k in 1:length(segment1)]) * sub_penalty)
end

# buils the actual similarity matrix
function make_similarity_matrix(seq1::Array{SubString{String}, 1},
                                seq2::Array{SubString{String}, 1},
                                tolerance::Float64=0.0, 
                                underspec_cost::Float64=0.25,
                                sub_penalty::Float64=1.0,
                                ins_del_basis::String = "empty",
                                ins_penalty::Float64 = 1.0)
    d = []
    function compare(x::Float64, y::Float64)
        return ((x - y) <= tolerance)
    end
    
    initial_vals = Dict("aboveleft" => 0.0,
                        "above"=> 0.0,
                        "left"=> 0.0,
                        "trace"=> 0.0,
                        "f"=> 0.0)
    
    d = [[copy(initial_vals) for i in vcat(seq2,"")] for j in vcat(seq1,"")]
    d[1][1]["f"] = 0
    
    for i in 1:(length(seq1))
        d[i+1][1]["f"] = d[i][1]["f"] + compare_segments(seq1[i], "empty", underspec_cost)
        d[i+1][1]["left"] = 1
    end
    
    for i in 1:(length(seq2))
        d[1][i+1]["f"] = d[1][i]["f"] + compare_segments("empty", seq2[i], underspec_cost)
        d[1][i+1]["above"] = 1
    end
    
    for i in (1:length(seq1))
        for j in (1:length(seq2))
            aboveleft = (d[i][j]["f"] + compare_segments(seq1[i], seq2[j], underspec_cost))
            left = d[i][j+1]["f"] + compare_segments(seq1[i], "empty", underspec_cost)
            above = d[i+1][j]["f"] + compare_segments("empty", seq2[j], underspec_cost)
            
            if (compare(aboveleft,above) & compare(aboveleft,left))
                d[i+1][j+1]["f"] = aboveleft
                d[i+1][j+1]["aboveleft"] = 1
            end
            
            if (compare(above, aboveleft) & compare(above, left))
                d[i+1][j+1]["f"] = above
                d[i+1][j+1]["above"] = 1
            end
            
            if (compare(left, aboveleft) & compare(left, above))
                d[i+1][j+1]["f"] = left
                d[i+1][j+1]["left"] = 1
            end
            d[i+1][j+1]["f"] = min(aboveleft, above, left)
        end
    end
    
    return (d)
end

# general wraper to calculate distance between two words
function get_distance(seq1::Array{SubString{String}, 1},
                      seq2::Array{SubString{String}, 1},
                      tolerance::Float64=0.0, 
                      underspec_cost::Float64=0.25, sub_penalty::Float64=1.0,
                      ins_del_basis::String = "empty",
                      ins_penalty::Float64 = 1.0)
    d = make_similarity_matrix(seq1, seq2)
    return (d[end][end]["f"])
end

# builds a feature dictionary from a feature file in tsv format
function build_feature_dic(file::String)
    d = Dict()
    f = open(file)
    j = false
    strings = readlines(f)
    for line in strings[2:end]
        vs=split(replace(line, "\n",""), "\t")
        d[vs[1]] = vs[2:end]
    end
    return (d)
end

# converts a string to a feature list
function to_features(word::String, features::Dict)
    fts::Array{SubString{String}, 1} = []
    for char in split(word, "")
        fts = vcat(fts, features[char])
    end
    return (fts)
end
