{
    "org": {
        "sql": "SELECT notes.* FROM notes WHERE (notes.status = \"$1\" OR notes.status = \"$2\" AND notes.closed_at > '2022-08-22 21:22:00.071876') AND (notes.tile BETWEEN 3221331576 AND 3221331583 OR notes.tile BETWEEN 3221331664 AND 3221331679 OR notes.tile BETWEEN 3221331696 AND 3221331711 OR notes.tile BETWEEN 3221331752 AND 3221331759 OR notes.tile BETWEEN 3221331768 AND 3221331775 OR notes.tile BETWEEN 3221331816 AND 3221331823 OR notes.tile BETWEEN 3221331832 AND 3221331967 OR notes.tile BETWEEN 3221337168 AND 3221337183 OR notes.tile BETWEEN 3221337200 AND 3221337215 OR notes.tile BETWEEN 3221337296 AND 3221337311 OR notes.tile BETWEEN 3221337328 AND 3221337599 OR notes.tile BETWEEN 3221337680 AND 3221337695 OR notes.tile BETWEEN 3221337712 AND 3221337727 OR notes.tile BETWEEN 3221337808 AND 3221337817 OR notes.tile BETWEEN 3221337820 AND 3221337821 OR notes.tile BETWEEN 3221337856 AND 3221337993 OR notes.tile BETWEEN 3221337996 AND 3221337997 OR notes.tile BETWEEN 3221338000 AND 3221338009 OR notes.tile BETWEEN 3221338012 AND 3221338013 OR notes.tile BETWEEN 3221338048 AND 3221338057 OR notes.tile BETWEEN 3221338060 AND 3221338061 OR notes.tile BETWEEN 3221338064 AND 3221338073 OR notes.tile BETWEEN 3221338076 AND 3221338077 OR notes.tile BETWEEN 3221342760 AND 3221342767 OR notes.tile BETWEEN 3221342776 AND 3221342783 OR notes.tile BETWEEN 3221342824 AND 3221342831 OR notes.tile BETWEEN 3221342840 AND 3221342975 OR notes.tile BETWEEN 3221343016 AND 3221343023 OR notes.tile BETWEEN 3221343032 AND 3221343039 OR notes.tile BETWEEN 3221343080 AND 3221343087 OR notes.tile BETWEEN 3221343096 AND 3221343231 OR notes.tile BETWEEN 3221343784 AND 3221343791 OR notes.tile BETWEEN 3221343800 AND 3221343807 OR notes.tile BETWEEN 3221343848 AND 3221343855 OR notes.tile BETWEEN 3221343864 AND 3221343999 OR notes.tile BETWEEN 3221344040 AND 3221344047 OR notes.tile BETWEEN 3221344128 AND 3221344144 OR notes.tile BETWEEN 3221344160 AND 3221344176 OR notes.tile BETWEEN 3221348352 AND 3221349001 OR notes.tile BETWEEN 3221349004 AND 3221349005 OR notes.tile BETWEEN 3221349008 AND 3221349017 OR notes.tile BETWEEN 3221349020 AND 3221349021 OR notes.tile BETWEEN 3221349056 AND 3221349065 OR notes.tile BETWEEN 3221349068 AND 3221349069 OR notes.tile BETWEEN 3221349072 AND 3221349081 OR notes.tile BETWEEN 3221349084 AND 3221349085 OR notes.tile BETWEEN 3221349120 AND 3221349257 OR notes.tile BETWEEN 3221349260 AND 3221349261 OR notes.tile BETWEEN 3221349264 AND 3221349273 OR notes.tile BETWEEN 3221349276 AND 3221349277 OR notes.tile BETWEEN 3221349312 AND 3221349321 OR notes.tile BETWEEN 3221349324 AND 3221349325 OR notes.tile BETWEEN 3221349328 AND 3221349337 OR notes.tile BETWEEN 3221349340 AND 3221349341 OR notes.tile BETWEEN 3221349376 AND 3221349648 OR notes.tile BETWEEN 3221349664 AND 3221349680 OR notes.tile BETWEEN 3221349760 AND 3221349776 OR notes.tile BETWEEN 3221349792 AND 3221349808 OR notes.tile BETWEEN 3221349888 AND 3221350025 OR notes.tile BETWEEN 3221350028 AND 3221350029 OR notes.tile BETWEEN 3221350032 AND 3221350041 OR notes.tile BETWEEN 3221350044 AND 3221350045 OR notes.tile BETWEEN 3221350080 AND 3221350089 OR notes.tile BETWEEN 3221350092 AND 3221350093 OR notes.tile BETWEEN 3221350096 AND 3221350105 OR notes.tile BETWEEN 3221350108 AND 3221350109 OR notes.tile BETWEEN 3221350144 AND 3221350160 OR notes.tile BETWEEN 3221350176 AND 3221350192 OR notes.tile BETWEEN 3221350272 AND 3221350281 OR notes.tile BETWEEN 3221350284 AND 3221350285 OR notes.tile IN (3221344056, 3221344058, 3221344146, 3221344152, 3221344154, 3221344178, 3221344184, 3221344186, 3221349650, 3221349656, 3221349658, 3221349682, 3221349688, 3221349690, 3221349778, 3221349784, 3221349786, 3221349810, 3221349816, 3221349818, 3221350162, 3221350168, 3221350170, 3221350194, 3221350200, 3221350202, 3221350288, 3221350290, 3221350296)) AND notes.latitude BETWEEN 10000000.0 AND 12000000.0 AND notes.longitude BETWEEN 10000000.0 AND 12000000.0 ORDER BY updated_at DESC LIMIT \"$3\"",
        "cost": 381.83,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT notes.* FROM notes WHERE (notes.status = \"$1\" OR notes.status = \"$2\" AND notes.closed_at > '2022-08-22 21:22:00.071876') AND (notes.tile BETWEEN 3221331576 AND 3221331583 OR notes.tile BETWEEN 3221331664 AND 3221331679 OR notes.tile BETWEEN 3221331696 AND 3221331711 OR notes.tile BETWEEN 3221331752 AND 3221331759 OR notes.tile BETWEEN 3221331768 AND 3221331775 OR notes.tile BETWEEN 3221331816 AND 3221331823 OR notes.tile BETWEEN 3221331832 AND 3221331967 OR notes.tile BETWEEN 3221337168 AND 3221337183 OR notes.tile BETWEEN 3221337200 AND 3221337215 OR notes.tile BETWEEN 3221337296 AND 3221337311 OR notes.tile BETWEEN 3221337328 AND 3221337599 OR notes.tile BETWEEN 3221337680 AND 3221337695 OR notes.tile BETWEEN 3221337712 AND 3221337727 OR notes.tile BETWEEN 3221337808 AND 3221337817 OR notes.tile BETWEEN 3221337820 AND 3221337821 OR notes.tile BETWEEN 3221337856 AND 3221337993 OR notes.tile BETWEEN 3221337996 AND 3221337997 OR notes.tile BETWEEN 3221338000 AND 3221338009 OR notes.tile BETWEEN 3221338012 AND 3221338013 OR notes.tile BETWEEN 3221338048 AND 3221338057 OR notes.tile BETWEEN 3221338060 AND 3221338061 OR notes.tile BETWEEN 3221338064 AND 3221338073 OR notes.tile BETWEEN 3221338076 AND 3221338077 OR notes.tile BETWEEN 3221342760 AND 3221342767 OR notes.tile BETWEEN 3221342776 AND 3221342783 OR notes.tile BETWEEN 3221342824 AND 3221342831 OR notes.tile BETWEEN 3221342840 AND 3221342975 OR notes.tile BETWEEN 3221343016 AND 3221343023 OR notes.tile BETWEEN 3221343032 AND 3221343039 OR notes.tile BETWEEN 3221343080 AND 3221343087 OR notes.tile BETWEEN 3221343096 AND 3221343231 OR notes.tile BETWEEN 3221343784 AND 3221343791 OR notes.tile BETWEEN 3221343800 AND 3221343807 OR notes.tile BETWEEN 3221343848 AND 3221343855 OR notes.tile BETWEEN 3221343864 AND 3221343999 OR notes.tile BETWEEN 3221344040 AND 3221344047 OR notes.tile BETWEEN 3221344128 AND 3221344144 OR notes.tile BETWEEN 3221344160 AND 3221344176 OR notes.tile BETWEEN 3221348352 AND 3221349001 OR notes.tile BETWEEN 3221349004 AND 3221349005 OR notes.tile BETWEEN 3221349008 AND 3221349017 OR notes.tile BETWEEN 3221349020 AND 3221349021 OR notes.tile BETWEEN 3221349056 AND 3221349065 OR notes.tile BETWEEN 3221349068 AND 3221349069 OR notes.tile BETWEEN 3221349072 AND 3221349081 OR notes.tile BETWEEN 3221349084 AND 3221349085 OR notes.tile BETWEEN 3221349120 AND 3221349257 OR notes.tile BETWEEN 3221349260 AND 3221349261 OR notes.tile BETWEEN 3221349264 AND 3221349273 OR notes.tile BETWEEN 3221349276 AND 3221349277 OR notes.tile BETWEEN 3221349312 AND 3221349321 OR notes.tile BETWEEN 3221349324 AND 3221349325 OR notes.tile BETWEEN 3221349328 AND 3221349337 OR notes.tile BETWEEN 3221349340 AND 3221349341 OR notes.tile BETWEEN 3221349376 AND 3221349648 OR notes.tile BETWEEN 3221349664 AND 3221349680 OR notes.tile BETWEEN 3221349760 AND 3221349776 OR notes.tile BETWEEN 3221349792 AND 3221349808 OR notes.tile BETWEEN 3221349888 AND 3221350025 OR notes.tile BETWEEN 3221350028 AND 3221350029 OR notes.tile BETWEEN 3221350032 AND 3221350041 OR notes.tile BETWEEN 3221350044 AND 3221350045 OR notes.tile BETWEEN 3221350080 AND 3221350089 OR notes.tile BETWEEN 3221350092 AND 3221350093 OR notes.tile BETWEEN 3221350096 AND 3221350105 OR notes.tile BETWEEN 3221350108 AND 3221350109 OR notes.tile BETWEEN 3221350144 AND 3221350160 OR notes.tile BETWEEN 3221350176 AND 3221350192 OR notes.tile BETWEEN 3221350272 AND 3221350281 OR notes.tile BETWEEN 3221350284 AND 3221350285 OR notes.tile IN (3221344056, 3221344058, 3221344146, 3221344152, 3221344154, 3221344178, 3221344184, 3221344186, 3221349650, 3221349656, 3221349658, 3221349682, 3221349688, 3221349690, 3221349778, 3221349784, 3221349786, 3221349810, 3221349816, 3221349818, 3221350162, 3221350168, 3221350170, 3221350194, 3221350200, 3221350202, 3221350288, 3221350290, 3221350296)) AND notes.latitude BETWEEN 10000000.0 AND 12000000.0 ORDER BY updated_at DESC LIMIT \"$3\"",
            "cost": 381.82,
            "rewrite_types": [
                "RemovePredicate"
            ]
        }
    ]
}