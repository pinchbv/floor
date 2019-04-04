# Publishing

This document describes step-by-step how to release a new version of the library to pub.

1. **floor_annotation**
    1. Update CHANGELOG
    1. Update version
    1. Update dependencies
    1. `pub get`
    
1. **floor**
    1. Update CHANGELOG
    1. Update README (with updated library versions)
    1. Update version
    1. Update dependencies
    1. `flutter packages get`
    
1. **floor_generator**
    1. Update CHANGELOG
    1. Update version
    1. Update dependencies
    1. `pub get`

1. Check if all dependencies can be resolved and project runs as expected

1. **floor_annotation** `pub publish`

1. **floor**
    1. Change path of **floor_annotation** to point to pub hosted package
    1. `pub publish`

1. **floor_generator**
    1. Change path of **floor_annotation** to point to pub hosted package
    1. `pub publish`

1. Change path of **floor_annotation** to point to local package
    1. **floor**
  	1. **floor_generator**
  	
1. Update README (with updated library versions) 	
  	
1. Push changes to repository  	 
