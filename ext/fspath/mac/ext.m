#include "ruby.h"
#include <AppKit/AppKit.h>
#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>

CFStringRef get_path(VALUE self){
	VALUE path = rb_iv_get(self, "@path");
	char *pathStr = StringValueCStr(path);
	CFStringRef pathRef = CFStringCreateWithCString(NULL, pathStr, kCFStringEncodingUTF8);

	if (!pathRef) {
		rb_raise(rb_eRuntimeError, "Can't convert path");
	}

	return pathRef;
}

CFURLRef get_url(VALUE self){
	CFStringRef pathRef = get_path(self);
	CFURLRef urlRef = CFURLCreateWithFileSystemPath(NULL, pathRef, kCFURLPOSIXPathStyle, false);
	CFRelease(pathRef);

	if (!urlRef) {
		rb_raise(rb_eRuntimeError, "Can't initialize url for path");
	}

	return urlRef;
}

void raise_cf_error(CFErrorRef errorRef){
	CFStringRef errorDescriptionRef = CFErrorCopyDescription(errorRef);
	CFRelease(errorRef);

	CFIndex length = CFStringGetLength(errorDescriptionRef);
	CFIndex maxSize = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8);
	char *errorDescription = (char *) malloc(maxSize);
	CFStringGetCString(errorDescriptionRef, errorDescription, maxSize, kCFStringEncodingUTF8);
	CFRelease(errorDescriptionRef);

	VALUE message = rb_str_new_cstr(errorDescription);
	free(errorDescription);

	rb_exc_raise(rb_exc_new3(rb_eRuntimeError, message));
}

static VALUE finder_label_number_get(VALUE self){
	CFURLRef urlRef = get_url(self);

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

	CFURLRef urlRef = get_url(self);

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

static VALUE spotlight_comment_get(VALUE self){
	ProcessSerialNumber psn = { 0, kCurrentProcess };
	NSAppleEventDescriptor *target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber bytes:&psn length:sizeof(ProcessSerialNumber)];
	NSAppleEventDescriptor *event = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite eventID:kASSubroutineEvent targetDescriptor:target returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];

	NSAppleEventDescriptor *subroutineDescriptor = [NSAppleEventDescriptor descriptorWithString:@"_get"];
	[event setParamDescriptor:subroutineDescriptor forKeyword:keyASSubroutineName];

	NSAppleEventDescriptor *parameters = [NSAppleEventDescriptor listDescriptor];
	CFURLRef urlRef = get_url(self);
	NSAppleEventDescriptor *fileUrlDescriptor = [NSAppleEventDescriptor descriptorWithFileURL:(NSURL *)urlRef];
	[parameters insertDescriptor:fileUrlDescriptor atIndex:0];
	[event setParamDescriptor:parameters forKeyword:keyDirectObject];

	NSDictionary *errors;
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"on _get(_path)\ntell application \"Finder\" to get comment of (_path as alias)\nend"];
	NSAppleEventDescriptor *result = [script executeAppleEvent:event error:&errors];

	[script release];
	[event release];
	[target release];
	[parameters release];
	[fileUrlDescriptor release];
	CFRelease(urlRef);
	[subroutineDescriptor release];

	if (result) {
		NSString *stringValue = [result stringValue];
		[result release];

		VALUE rbResult = rb_str_new_cstr([stringValue UTF8String]);
		[stringValue release];

		return rbResult;
	} else {
		NSString *errorsDescription = [errors description];
		[errors release];

		VALUE rbMessage = rb_str_new_cstr([errorsDescription UTF8String]);
		[errorsDescription release];

		rb_exc_raise(rb_exc_new3(rb_eRuntimeError, rbMessage));
	}
}

static VALUE spotlight_comment_set(VALUE self, VALUE commentValue){
	commentValue = rb_obj_as_string(commentValue);

	ProcessSerialNumber psn = { 0, kCurrentProcess };
	NSAppleEventDescriptor *target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber bytes:&psn length:sizeof(ProcessSerialNumber)];
	NSAppleEventDescriptor *event = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite eventID:kASSubroutineEvent targetDescriptor:target returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];

	NSAppleEventDescriptor *subroutineDescriptor = [NSAppleEventDescriptor descriptorWithString:@"_set"];
	[event setParamDescriptor:subroutineDescriptor forKeyword:keyASSubroutineName];

	NSAppleEventDescriptor *parameters = [NSAppleEventDescriptor listDescriptor];
	CFURLRef urlRef = get_url(self);
	NSAppleEventDescriptor *fileUrlDescriptor = [NSAppleEventDescriptor descriptorWithFileURL:(NSURL *)urlRef];
	[parameters insertDescriptor:fileUrlDescriptor atIndex:0];
	NSString *comment = [NSString stringWithCString:StringValueCStr(commentValue) encoding:NSUTF8StringEncoding];
	NSAppleEventDescriptor *commentDescriptor = [NSAppleEventDescriptor descriptorWithString:comment];
	[parameters insertDescriptor:commentDescriptor atIndex:0];
	[event setParamDescriptor:parameters forKeyword:keyDirectObject];

	NSDictionary *errors;
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"on _set(_path, _comment)\ntell application \"Finder\" to set comment of (_path as alias) to _comment\nend"];
	NSAppleEventDescriptor *result = [script executeAppleEvent:event error:&errors];

	[script release];
	[event release];
	[target release];
	[parameters release];
	[commentDescriptor release];
	[comment release];
	[fileUrlDescriptor release];
	CFRelease(urlRef);
	[subroutineDescriptor release];

	if (result) {
		[result release];
	} else {
		NSString *errorsDescription = [errors description];
		[errors release];

		VALUE rbMessage = rb_str_new_cstr([errorsDescription UTF8String]);
		[errorsDescription release];

		rb_exc_raise(rb_exc_new3(rb_eRuntimeError, rbMessage));
	}

	return Qnil;
}

static VALUE move_to_trash(VALUE self){
	CFStringRef pathRef = get_path(self);
	NSString *path = (NSString *)pathRef;

	NSString *dir = [path stringByDeletingLastPathComponent];
	NSString *name = [path lastPathComponent];
	NSArray *names = [NSArray arrayWithObject:name];
	BOOL success = [[NSWorkspace sharedWorkspace]
		performFileOperation:NSWorkspaceRecycleOperation
		source:dir
		destination:@""
		files:names
		tag:nil];
	[names release];
	[name release];
	[dir release];

	CFRelease(pathRef);

	return success ? Qtrue : Qfalse;
}

void Init_ext() {
	VALUE cFSPath = rb_const_get(rb_cObject, rb_intern("FSPath"));
	VALUE mMac = rb_const_get(cFSPath, rb_intern("Mac"));
	rb_define_private_method(mMac, "finder_label_number", finder_label_number_get, 0);
	rb_define_private_method(mMac, "finder_label_number=", finder_label_number_set, 1);
	rb_define_method(mMac, "spotlight_comment", spotlight_comment_get, 0);
	rb_define_method(mMac, "spotlight_comment=", spotlight_comment_set, 1);
	rb_define_method(mMac, "move_to_trash", move_to_trash, 0);
}
