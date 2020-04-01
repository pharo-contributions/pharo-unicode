# Unicode for Pharo

In Pharo we can deal with and represent any Unicode character and string, but there are still some important pieces of functionality missing. The goal of the Pharo Unicode project is to gradually improve and expand Unicode support in Pharo.

Normalization is implemented. The development branch also contains a work in progress implementation of Collation. Much work remains to be done and contributions are more than welcome.

For additional information, see [An Implementation of Unicode Normalization](https://medium.com/concerning-pharo/an-implementation-of-unicode-normalization-7c6719068f43#.s6vks48vq).

Authors: Sven Van Caekenberghe, Henrik Sperre Johansen


## Installation

Unicode for Pharo has been tested on Pharo 8.

To install, evaluate:

```smalltalk
Metacello new 
	repository: 'github://pharo-contributions/pharo-unicode/src';
	baseline: 'Unicode';
	load.
```


## Historical

This is a port of the project from SmalltalkHub.  The original project is at <http://smalltalkhub.com/#!/~Pharo/Unicode>.
