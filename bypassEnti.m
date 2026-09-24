#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>

static id Dummy_nil(id self, SEL _cmd) {
    return nil;
}

static void Dummy_void(id self, SEL _cmd) {
}

static NSInteger Dummy_authStatus(id self, SEL _cmd) {
    return 3;
}

static void hook_class_method(Class cls, SEL sel, IMP imp, const char *types) {
    if (!cls || !sel) return;
    Class meta = object_getClass((id)cls);
    if (meta) {
        class_replaceMethod(meta, sel, imp, types);
    }
}

static void hook_instance_method(Class cls, SEL sel, IMP imp, const char *types) {
    if (!cls || !sel) return;
    class_replaceMethod(cls, sel, imp, types);
}

__attribute__((constructor))
static void init_siri_bypass(void) {
    @autoreleasepool {
        dlopen("/System/Library/Frameworks/Intents.framework/Intents", RTLD_NOW);

        Class vocabClass = objc_getClass("INVocabulary");
        if (vocabClass) {
            hook_class_method(vocabClass, sel_registerName("sharedVocabulary"), (IMP)Dummy_nil, "@@:");
            hook_instance_method(vocabClass, sel_registerName("init"), (IMP)Dummy_nil, "@@:");
            hook_instance_method(vocabClass, sel_registerName("_THROW_EXCEPTION_FOR_PROCESS_MISSING_ENTITLEMENT_com_apple_developer_siri"), (IMP)Dummy_void, "v@:");
            hook_instance_method(vocabClass, sel_registerName("setVocabularyStrings:ofType:"), (IMP)Dummy_void, "v@:@@");
            hook_instance_method(vocabClass, sel_registerName("removeAllVocabularyStrings"), (IMP)Dummy_void, "v@:");
        }

        Class prefClass = objc_getClass("INPreferences");
        if (prefClass) {
            hook_class_method(prefClass, sel_registerName("sharedPreferences"), (IMP)Dummy_nil, "@@:");
            hook_class_method(prefClass, sel_registerName("siriAuthorizationStatus"), (IMP)Dummy_authStatus, "q@:");
            hook_instance_method(prefClass, sel_registerName("siriAuthorizationStatus"), (IMP)Dummy_authStatus, "q@:");
            hook_instance_method(prefClass, sel_registerName("_siriAuthorizationStatus"), (IMP)Dummy_authStatus, "q@:");
            hook_instance_method(prefClass, sel_registerName("assertThisProcessHasSiriEntitlement"), (IMP)Dummy_void, "v@:");
        }
    }
}
