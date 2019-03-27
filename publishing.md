# Publishing

This document describes step-by-step how to release a new version of the library to pub.

1. **floor_annotation** (because other packages depend on it)
    - Update version
    - Update CHANGELOG
    - `pub publish`
    
1. **floor**
    - Update version
    - Update dependencies (most important floor_annotation)
    - Change path of floor_annotation to point to pub hosted package
    - Update CHANGELOG
    - Update README (with updated library versions)
    - `pub publish`
    
1. **floor_generator**
    - Update version
    - Update dependencies (most important floor_annotation)
    - Change path of floor_annotation to point to pub hosted package
    - Update CHANGELOG
    - Update README (with updated library versions)
    - `pub publish`
