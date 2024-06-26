@testset "desiralizers" begin
    @test LightOSM.string_deserializer(:xml) == LightXML.parse_string
    @test LightOSM.string_deserializer(:osm) == LightXML.parse_string
    @test LightOSM.string_deserializer(:json) == JSON.parse
    @test_throws ArgumentError LightOSM.string_deserializer(:other) 
end

@testset "string utils" begin
    #tryparse_string_to_number
    @test LightOSM.tryparse_string_to_number("1") === 1
    @test LightOSM.tryparse_string_to_number("1.0") === 1.0
    @test LightOSM.tryparse_string_to_number("a") === "a"

    # remove_non_numeric
    @test LightOSM.remove_non_numeric("1.0") === 1.0
    @test LightOSM.remove_non_numeric("1") === 1
    @test LightOSM.remove_non_numeric("a") === 0

    # remove_sub_string_after
    @test LightOSM.remove_sub_string_after("after_this_remove", "after_this") === ""
    @test LightOSM.remove_sub_string_after("keep_after_this_remove", "after_this") === "keep_"
    @test LightOSM.remove_sub_string_after("keep_after_this_remove_after_this", "after_this") === "keep_"

    # remove_numeric
    @test LightOSM.remove_numeric("a1a") === "aa"
    @test LightOSM.remove_numeric("a1.0a") === "aa"
    @test LightOSM.remove_numeric("aa1bb2") === "aabb"
end

@testset "array tools" begin
    # trailing_elements
    @test LightOSM.trailing_elements([1]) == [1,1]
    @test LightOSM.trailing_elements([1,3]) == [1,3]
    @test LightOSM.trailing_elements([1,2,3]) == [1,3]

    # first_common_trailing_element
    @test LightOSM.first_common_trailing_element([1,2],[2,1]) == 1
    @test LightOSM.first_common_trailing_element([1,2],[2,2]) == 2
    @test LightOSM.first_common_trailing_element([1,3, 2],[2,3, 2]) == 2
    @test_throws ArgumentError LightOSM.first_common_trailing_element([1,2],[3,4]) == 3
    @test_throws ArgumentError LightOSM.first_common_trailing_element([1,5, 2],[3,5, 4]) == 3

    # join_two_arrays_on_common_trailing_elements
    @test LightOSM.join_two_arrays_on_common_trailing_elements([1,2,3],[3,4,5]) == [1,2,3,4,5]
    @test LightOSM.join_two_arrays_on_common_trailing_elements([1,2,3],[5,4,3]) == [1,2,3,4,5]
    @test LightOSM.join_two_arrays_on_common_trailing_elements([3,2,1],[5,4,3]) == [1,2,3,4,5]
    @test LightOSM.join_two_arrays_on_common_trailing_elements([3,2,1],[3,4,5]) == [1,2,3,4,5]
    @test LightOSM.join_two_arrays_on_common_trailing_elements([3,2,1],[1,4,3]) == [1,2,3,4,1]

    # join_arrays_on_common_trailing_elements
    @test LightOSM.join_arrays_on_common_trailing_elements([1,2],[2,3],[3,4]) == [1,2,3,4]
    @test LightOSM.join_arrays_on_common_trailing_elements([1,2],[4,3],[3,2]) == [1,2,3,4]
    @test LightOSM.join_arrays_on_common_trailing_elements([1,2]) == [1,2]
    @test_throws ErrorException LightOSM.join_arrays_on_common_trailing_elements([1,2],[4,3],[5,6]) == [1,2,3,4]

    # flatten
    @test LightOSM.flatten([1]) == [1]
    @test LightOSM.flatten([[1,2],[[3], [4]],1,2]) == [1,2,3,4,1,2]
end

@testset "file_deserializer" begin
    # check_valid_filename
    @test LightOSM.check_valid_filename("map.osm")
    @test LightOSM.check_valid_filename("map.json")
    @test LightOSM.check_valid_filename("map.xml")
    @test_throws ArgumentError LightOSM.check_valid_filename("map.osm.doc")
    @test_throws ArgumentError LightOSM.check_valid_filename("map.json.doc")
    @test_throws ArgumentError LightOSM.check_valid_filename("map.xml.doc")
    @test_throws ArgumentError LightOSM.check_valid_filename("map")

    # file_deserializer
    files = ["data.osm", "data.xml", "data.json", "data.doc"]
    foreach(touch, files)

    @test LightOSM.file_deserializer("data.osm") == LightXML.parse_file
    @test LightOSM.file_deserializer("data.xml") == LightXML.parse_file
    @test LightOSM.file_deserializer("data.json") == JSON.parsefile
    @test_throws ArgumentError LightOSM.file_deserializer("data.doc")

    foreach(rm, files) # tidy up
end

@testset "validate_save_location" begin
    osmfilename = "folder/filename.osm"
    @test LightOSM.validate_save_location(osmfilename, :osm) == osmfilename
    @test_throws ArgumentError LightOSM.validate_save_location(osmfilename, :xml)
    @test_throws ArgumentError LightOSM.validate_save_location(osmfilename, :json)

    jsonfilename = "folder/filename.json"
    @test LightOSM.validate_save_location(jsonfilename, :json) == jsonfilename
    @test_throws ArgumentError LightOSM.validate_save_location(jsonfilename, :osm)
    @test_throws ArgumentError LightOSM.validate_save_location(jsonfilename, :xml)

    xmlfilename = "folder/filename.xml"
    @test LightOSM.validate_save_location(xmlfilename, :xml) == xmlfilename
    @test_throws ArgumentError LightOSM.validate_save_location(xmlfilename, :osm)
    @test_throws ArgumentError LightOSM.validate_save_location(xmlfilename, :json)

    noextension = "filename"
    @test LightOSM.validate_save_location(noextension, :xml) == noextension * ".xml"
    @test LightOSM.validate_save_location(noextension, :json) == noextension * ".json"
    @test LightOSM.validate_save_location(noextension, :osm) == noextension * ".osm"
end