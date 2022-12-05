import Foundation

final class NewSearchSectionsBuilder {
    
    static func makeSections<Option>(_ options: [Option], rowsBuilder: ([Option]) -> [ListRowConfiguration]) -> [ListSectionConfiguration] {
        
        var sections: [ListSectionConfiguration] = []
        
        if options.isNotEmpty {
            sections.append(
                ListSectionConfiguration(
                    id: "otherOptionsSectionID",
                    title: Loc.everywhere,
                    rows: rowsBuilder(options)
                )
            )
        }
        
        return sections
    }
    
}
