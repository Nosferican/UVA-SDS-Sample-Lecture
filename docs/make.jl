using Documenter

makedocs(sitename = "DS6015",
         source = joinpath("docs", "src"),
         pages = [
            "Syllabus" => "index.md",
            "GraphQL" => "GraphQL.md",
            ],
            )

deploydocs(repo = "github.com/Nosferican/UVA-SDS-Sample-Lecture.git",
           push_preview = true,
           devbranch = "main")
