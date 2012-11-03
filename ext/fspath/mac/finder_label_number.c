#include "ruby.h"
#include <CoreServices/CoreServices.h>

CFURLRef url_for_path(VALUE fsPath){
	VALUE path = rb_iv_get(fsPath, "@path");
	char *pathStr = StringValueCStr(path);

	CFStringRef pathRef = CFStringCreateWithCString(NULL, pathStr, kCFStringEncodingUTF8);
	if (!pathRef) {
		rb_raise(rb_eRuntimeError, "Can't convert path");
	}

	CFURLRef urlRef = CFURLCreateWithFileSystemPath(NULL, pathRef, kCFURLPOSIXPathStyle, false);
	CFRelease(pathRef);
	if (!urlRef) {
		rb_raise(rb_eRuntimeError, "Can't initialize url for path");
	}

	return urlRef;
}

void raise_cf_error(CFErrorRef errorRef){
	CFStringRef errorDescriptionRef = CFErrorCopyDescription(errorRef);

	const char *errorDescriptionC = CFStringGetCStringPtr(errorDescriptionRef, kCFStringEncodingUTF8);
	if (errorDescriptionC) {
		rb_raise(rb_eRuntimeError, errorDescriptionC);
	} else {
		CFIndex length = CFStringGetLength(errorDescriptionRef);
		CFIndex maxSize = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8);
		char *errorDescription = (char *) malloc(maxSize);
		CFStringGetCString(errorDescriptionRef, errorDescription, maxSize, kCFStringEncodingUTF8);
		rb_raise(rb_eRuntimeError, errorDescription);
	}
}

static VALUE finder_label_number_get(VALUE self){
	CFURLRef urlRef = url_for_path(self);

	CFErrorRef errorRef;
	CFNumberRef labelNumberRef;
	bool ok = CFURLCopyResourcePropertyForKey(urlRef, kCFURLLabelNumberKey, &labelNumberRef, &errorRef);
	CFRelease(urlRef);

	if (!ok) {
		raise_cf_error(errorRef);
	}

	SInt32 labelNumberValue;
	CFNumberGetValue(labelNumberRef, kCFNumberSInt32Type, &labelNumberValue);
	CFRelease(labelNumberRef);

	return INT2NUM(labelNumberValue);
}

static VALUE finder_label_number_set(VALUE self, VALUE labelNumber){
	if (TYPE(labelNumber) != T_FIXNUM) {
		rb_raise(rb_eTypeError, "invalid type for labelNumber");
	}

	SInt32 labelNumberValue = NUM2INT(labelNumber);
	if (labelNumberValue < 0 || labelNumberValue > 7) {
		rb_raise(rb_eArgError, "label number can be in range 0..7");
	}

	CFURLRef urlRef = url_for_path(self);

	CFNumberRef labelNumberRef = CFNumberCreate(NULL, kCFNumberSInt32Type, &labelNumberValue);

	CFErrorRef errorRef;
	bool ok = CFURLSetResourcePropertyForKey(urlRef, kCFURLLabelNumberKey, labelNumberRef, &errorRef);
	CFRelease(labelNumberRef);
	CFRelease(urlRef);

	if (!ok) {
		raise_cf_error(errorRef);
	}

	return Qnil;
}

void Init_finder_label_number() {
	VALUE cFSPath = rb_const_get(rb_cObject, rb_intern("FSPath"));
	VALUE mMac = rb_const_get(cFSPath, rb_intern("Mac"));
	rb_define_private_method(mMac, "finder_label_number", finder_label_number_get, 0);
	rb_define_private_method(mMac, "finder_label_number=", finder_label_number_set, 1);
}
