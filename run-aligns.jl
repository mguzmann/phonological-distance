## Simple way of calling the aligner and distance calculator

# we load the align and distance functions
include("./align_functions.jl")

# we read the feature specification for the given langauge
features = build_feature_dic("features_spanish.tsv");

# we read the list of words
verbs = readlines(open("verbs.ipa"));

# we calculate all pairwise distances for all words
distances = [];
for verb_j in 1:length(verbs)
    verb_1 = verbs[verb_j]
    println(verb_1,", ", verb_j, ", ", string(length(verbs)))
    for verb_2 in verbs
        dist = get_distance(to_features(verb_1, features), 
                            to_features(verb_2, features))
        print(verb_2, " ", dist, " -- ")
        push!(distances, [verb_1, verb_2, dist])
    end
    println(" ")
end

# we write the calculated distances to a file
open("distances.txt", "w") do f
    for dist in distances
        write(f, string(dist[1]*"\t"*dist[2]*"\t", dist[3])*"\n")
    end
end
