local ffi = require 'ffi'
ffi.cdef[[
typedef struct spEventData {
	const char* const name;
	int Value;
	float floatValue;
	const char* stringValue;
	const char* audioPath;
	float volume;
	float balance;
} spEventData;
 spEventData* spEventData_create (const char* name);
 void spEventData_dispose (spEventData* self);
typedef struct spEvent {
	spEventData* const data;
	float const time;
	int Value;
	float floatValue;
	const char* stringValue;
	float volume;
	float balance;
} spEvent;
 spEvent* spEvent_create (float time, spEventData* data);
 void spEvent_dispose (spEvent* self);
struct spAttachmentLoader;
typedef enum {
	SP_ATTACHMENT_REGION,
	SP_ATTACHMENT_BOUNDING_BOX,
	SP_ATTACHMENT_MESH,
	SP_ATTACHMENT_LINKED_MESH,
	SP_ATTACHMENT_PATH,
	SP_ATTACHMENT_POINT,
	SP_ATTACHMENT_CLIPPING
} spAttachmentType;
typedef struct spAttachment {
	const char* const name;
	const spAttachmentType type;
	const void* const vtable;
	int refCount;
	struct spAttachmentLoader* attachmentLoader;
} spAttachment;
void spAttachment_dispose (spAttachment* self);
spAttachment* spAttachment_copy (spAttachment* self);
typedef struct spTimeline spTimeline;
struct spSkeleton;
typedef struct spAnimation {
	const char* const name;
	float duration;
	int timelinesCount;
	spTimeline** timelines;
} spAnimation;
typedef enum {
	SP_MIX_BLEND_SETUP,
	SP_MIX_BLEND_FIRST,
	SP_MIX_BLEND_REPLACE,
	SP_MIX_BLEND_ADD
} spMixBlend;
typedef enum {
	SP_MIX_DIRECTION_IN,
	SP_MIX_DIRECTION_OUT
} spMixDirection;
 spAnimation* spAnimation_create (const char* name, int timelinesCount);
 void spAnimation_dispose (spAnimation* self);
 void spAnimation_apply (const spAnimation* self, struct spSkeleton* skeleton, float lastTime, float time, int loop,
		spEvent** events, int* eventsCount, float alpha, spMixBlend blend, spMixDirection direction);
typedef enum {
	SP_TIMELINE_ROTATE,
	SP_TIMELINE_TRANSLATE,
	SP_TIMELINE_SCALE,
	SP_TIMELINE_SHEAR,
	SP_TIMELINE_ATTACHMENT,
	SP_TIMELINE_COLOR,
	SP_TIMELINE_DEFORM,
	SP_TIMELINE_EVENT,
	SP_TIMELINE_DRAWORDER,
	SP_TIMELINE_IKCONSTRAINT,
	SP_TIMELINE_TRANSFORMCONSTRAINT,
	SP_TIMELINE_PATHCONSTRAINTPOSITION,
	SP_TIMELINE_PATHCONSTRAINTSPACING,
	SP_TIMELINE_PATHCONSTRAINTMIX,
	SP_TIMELINE_TWOCOLOR
} spTimelineType;
struct spTimeline {
	const spTimelineType type;
	const void* const vtable;
};
 void spTimeline_dispose (spTimeline* self);
 void spTimeline_apply (const spTimeline* self, struct spSkeleton* skeleton, float lastTime, float time, spEvent** firedEvents,
		int* eventsCount, float alpha, spMixBlend blend, spMixDirection direction);
 int spTimeline_getPropertyId (const spTimeline* self);
typedef struct spCurveTimeline {
	spTimeline super;
	float* curves; 
} spCurveTimeline;
 void spCurveTimeline_setLinear (spCurveTimeline* self, int frameIndex);
 void spCurveTimeline_setStepped (spCurveTimeline* self, int frameIndex);
 void spCurveTimeline_setCurve (spCurveTimeline* self, int frameIndex, float cx1, float cy1, float cx2, float cy2);
 float spCurveTimeline_getCurvePercent (const spCurveTimeline* self, int frameIndex, float percent);
typedef struct spBaseTimeline {
	spCurveTimeline super;
	int const framesCount;
	float* const frames; 
	int boneIndex;
} spBaseTimeline;
static const int ROTATE_PREV_TIME = -2, ROTATE_PREV_ROTATION = -1;
static const int ROTATE_ROTATION = 1;
static const int ROTATE_ENTRIES = 2;
typedef struct spBaseTimeline spRotateTimeline;
 spRotateTimeline* spRotateTimeline_create (int framesCount);
 void spRotateTimeline_setFrame (spRotateTimeline* self, int frameIndex, float time, float angle);
static const int TRANSLATE_ENTRIES = 3;
typedef struct spBaseTimeline spTranslateTimeline;
 spTranslateTimeline* spTranslateTimeline_create (int framesCount);
 void spTranslateTimeline_setFrame (spTranslateTimeline* self, int frameIndex, float time, float x, float y);
typedef struct spBaseTimeline spScaleTimeline;
 spScaleTimeline* spScaleTimeline_create (int framesCount);
 void spScaleTimeline_setFrame (spScaleTimeline* self, int frameIndex, float time, float x, float y);
typedef struct spBaseTimeline spShearTimeline;
 spShearTimeline* spShearTimeline_create (int framesCount);
 void spShearTimeline_setFrame (spShearTimeline* self, int frameIndex, float time, float x, float y);
static const int COLOR_ENTRIES = 5;
typedef struct spColorTimeline {
	spCurveTimeline super;
	int const framesCount;
	float* const frames; 
	int slotIndex;
} spColorTimeline;
 spColorTimeline* spColorTimeline_create (int framesCount);
 void spColorTimeline_setFrame (spColorTimeline* self, int frameIndex, float time, float r, float g, float b, float a);
static const int TWOCOLOR_ENTRIES = 8;
typedef struct spTwoColorTimeline {
	spCurveTimeline super;
	int const framesCount;
	float* const frames; 
	int slotIndex;
} spTwoColorTimeline;
 spTwoColorTimeline* spTwoColorTimeline_create (int framesCount);
 void spTwoColorTimeline_setFrame (spTwoColorTimeline* self, int frameIndex, float time, float r, float g, float b, float a, float r2, float g2, float b2);
typedef struct spAttachmentTimeline {
	spTimeline super;
	int const framesCount;
	float* const frames; 
	int slotIndex;
	const char** const attachmentNames;
} spAttachmentTimeline;
 spAttachmentTimeline* spAttachmentTimeline_create (int framesCount);
 void spAttachmentTimeline_setFrame (spAttachmentTimeline* self, int frameIndex, float time, const char* attachmentName);
typedef struct spEventTimeline {
	spTimeline super;
	int const framesCount;
	float* const frames; 
	spEvent** const events;
} spEventTimeline;
 spEventTimeline* spEventTimeline_create (int framesCount);
 void spEventTimeline_setFrame (spEventTimeline* self, int frameIndex, spEvent* event);
typedef struct spDrawOrderTimeline {
	spTimeline super;
	int const framesCount;
	float* const frames; 
	const int** const drawOrders;
	int const slotsCount;
} spDrawOrderTimeline;
 spDrawOrderTimeline* spDrawOrderTimeline_create (int framesCount, int slotsCount);
 void spDrawOrderTimeline_setFrame (spDrawOrderTimeline* self, int frameIndex, float time, const int* drawOrder);
typedef struct spDeformTimeline {
	spCurveTimeline super;
	int const framesCount;
	float* const frames; 
	int const frameVerticesCount;
	const float** const frameVertices;
	int slotIndex;
	spAttachment* attachment;
} spDeformTimeline;
 spDeformTimeline* spDeformTimeline_create (int framesCount, int frameVerticesCount);
 void spDeformTimeline_setFrame (spDeformTimeline* self, int frameIndex, float time, float* vertices);
static const int IKCONSTRAINT_ENTRIES = 6;
typedef struct spIkConstraintTimeline {
	spCurveTimeline super;
	int const framesCount;
	float* const frames; 
	int ikConstraintIndex;
} spIkConstraintTimeline;
 spIkConstraintTimeline* spIkConstraintTimeline_create (int framesCount);
 void spIkConstraintTimeline_setFrame (spIkConstraintTimeline* self, int frameIndex, float time, float mix, float softness, int bendDirection, int  compress, int  stretch);
static const int TRANSFORMCONSTRAINT_ENTRIES = 5;
typedef struct spTransformConstraintTimeline {
	spCurveTimeline super;
	int const framesCount;
	float* const frames; 
	int transformConstraintIndex;
} spTransformConstraintTimeline;
 spTransformConstraintTimeline* spTransformConstraintTimeline_create (int framesCount);
 void spTransformConstraintTimeline_setFrame (spTransformConstraintTimeline* self, int frameIndex, float time, float rotateMix, float translateMix, float scaleMix, float shearMix);
static const int PATHCONSTRAINTPOSITION_ENTRIES = 2;
typedef struct spPathConstraintPositionTimeline {
	spCurveTimeline super;
	int const framesCount;
	float* const frames; 
	int pathConstraintIndex;
} spPathConstraintPositionTimeline;
 spPathConstraintPositionTimeline* spPathConstraintPositionTimeline_create (int framesCount);
 void spPathConstraintPositionTimeline_setFrame (spPathConstraintPositionTimeline* self, int frameIndex, float time, float value);
static const int PATHCONSTRAINTSPACING_ENTRIES = 2;
typedef struct spPathConstraintSpacingTimeline {
	spCurveTimeline super;
	int const framesCount;
	float* const frames; 
	int pathConstraintIndex;
} spPathConstraintSpacingTimeline;
 spPathConstraintSpacingTimeline* spPathConstraintSpacingTimeline_create (int framesCount);
 void spPathConstraintSpacingTimeline_setFrame (spPathConstraintSpacingTimeline* self, int frameIndex, float time, float value);
static const int PATHCONSTRAINTMIX_ENTRIES = 3;
typedef struct spPathConstraintMixTimeline {
	spCurveTimeline super;
	int const framesCount;
	float* const frames; 
	int pathConstraintIndex;
} spPathConstraintMixTimeline;
 spPathConstraintMixTimeline* spPathConstraintMixTimeline_create (int framesCount);
 void spPathConstraintMixTimeline_setFrame (spPathConstraintMixTimeline* self, int frameIndex, float time, float rotateMix, float translateMix);
typedef enum {
	SP_TRANSFORMMODE_NORMAL,
	SP_TRANSFORMMODE_ONLYTRANSLATION,
	SP_TRANSFORMMODE_NOROTATIONORREFLECTION,
	SP_TRANSFORMMODE_NOSCALE,
	SP_TRANSFORMMODE_NOSCALEORREFLECTION
} spTransformMode;
typedef struct spBoneData spBoneData;
struct spBoneData {
	const int index;
	const char* const name;
	spBoneData* const parent;
	float length;
	float x, y, rotation, scaleX, scaleY, shearX, shearY;
	spTransformMode transformMode;
	int skinRequired;
};
 spBoneData* spBoneData_create (int index, const char* name, spBoneData* parent);
 void spBoneData_dispose (spBoneData* self);
typedef struct spColor {
	float r, g, b, a;
} spColor;
 spColor* spColor_create();
 void spColor_dispose(spColor* self);
 void spColor_setFromFloats(spColor* color, float r, float g, float b, float a);
 void spColor_setFromColor(spColor* color, spColor* otherColor);
 void spColor_addFloats(spColor* color, float r, float g, float b, float a);
 void spColor_addColor(spColor* color, spColor* otherColor);
 void spColor_clamp(spColor* color);
typedef enum {
	SP_BLEND_MODE_NORMAL, SP_BLEND_MODE_ADDITIVE, SP_BLEND_MODE_MULTIPLY, SP_BLEND_MODE_SCREEN
} spBlendMode;
typedef struct spSlotData {
	const int index;
	const char* const name;
	const spBoneData* const boneData;
	const char* attachmentName;
	spColor color;
	spColor* darkColor;
	spBlendMode blendMode;
} spSlotData;
 spSlotData* spSlotData_create (const int index, const char* name, spBoneData* boneData);
 void spSlotData_dispose (spSlotData* self);
 void spSlotData_setAttachmentName (spSlotData* self, const char* attachmentName);
typedef struct spIkConstraintData {
	const char* const name;
	int order;
	int  skinRequired;
	int bonesCount;
	spBoneData** bones;
	spBoneData* target;
	int bendDirection;
	int  compress;
	int  stretch;
	int  uniform;
	float mix;
	float softness;
} spIkConstraintData;
 spIkConstraintData* spIkConstraintData_create (const char* name);
 void spIkConstraintData_dispose (spIkConstraintData* self);
typedef struct spTransformConstraintData {
	const char* const name;
	int order;
	int skinRequired;
	int bonesCount;
	spBoneData** const bones;
	spBoneData* target;
	float rotateMix, translateMix, scaleMix, shearMix;
	float offsetRotation, offsetX, offsetY, offsetScaleX, offsetScaleY, offsetShearY;
	int  relative;
	int  local;
} spTransformConstraintData;
 spTransformConstraintData* spTransformConstraintData_create (const char* name);
 void spTransformConstraintData_dispose (spTransformConstraintData* self);
typedef enum {
	SP_POSITION_MODE_FIXED, SP_POSITION_MODE_PERCENT
} spPositionMode;
typedef enum {
	SP_SPACING_MODE_LENGTH, SP_SPACING_MODE_FIXED, SP_SPACING_MODE_PERCENT
} spSpacingMode;
typedef enum {
	SP_ROTATE_MODE_TANGENT, SP_ROTATE_MODE_CHAIN, SP_ROTATE_MODE_CHAIN_SCALE
} spRotateMode;
typedef struct spPathConstraintData {
	const char* const name;
	int order;
	int skinRequired;
	int bonesCount;
	spBoneData** const bones;
	spSlotData* target;
	spPositionMode positionMode;
	spSpacingMode spacingMode;
	spRotateMode rotateMode;
	float offsetRotation;
	float position, spacing, rotateMix, translateMix;
} spPathConstraintData;
 spPathConstraintData* spPathConstraintData_create (const char* name);
 void spPathConstraintData_dispose (spPathConstraintData* self);
typedef struct spFloatArray { int size; int capacity; float* items; } spFloatArray;  spFloatArray* spFloatArray_create(int initialCapacity);  void spFloatArray_dispose(spFloatArray* self);  void spFloatArray_clear(spFloatArray* self);  spFloatArray* spFloatArray_setSize(spFloatArray* self, int newSize);  void spFloatArray_ensureCapacity(spFloatArray* self, int newCapacity);  void spFloatArray_add(spFloatArray* self, float value);  void spFloatArray_addAll(spFloatArray* self, spFloatArray* other);  void spFloatArray_addAllValues(spFloatArray* self, float* values, int offset, int count);  void spFloatArray_removeAt(spFloatArray* self, int index);  int spFloatArray_contains(spFloatArray* self, float value);  float spFloatArray_pop(spFloatArray* self);  float spFloatArray_peek(spFloatArray* self);
typedef struct spIntArray { int size; int capacity; int* items; } spIntArray;  spIntArray* spIntArray_create(int initialCapacity);  void spIntArray_dispose(spIntArray* self);  void spIntArray_clear(spIntArray* self);  spIntArray* spIntArray_setSize(spIntArray* self, int newSize);  void spIntArray_ensureCapacity(spIntArray* self, int newCapacity);  void spIntArray_add(spIntArray* self, int value);  void spIntArray_addAll(spIntArray* self, spIntArray* other);  void spIntArray_addAllValues(spIntArray* self, int* values, int offset, int count);  void spIntArray_removeAt(spIntArray* self, int index);  int spIntArray_contains(spIntArray* self, int value);  int spIntArray_pop(spIntArray* self);  int spIntArray_peek(spIntArray* self);
typedef struct spShortArray { int size; int capacity; short* items; } spShortArray;  spShortArray* spShortArray_create(int initialCapacity);  void spShortArray_dispose(spShortArray* self);  void spShortArray_clear(spShortArray* self);  spShortArray* spShortArray_setSize(spShortArray* self, int newSize);  void spShortArray_ensureCapacity(spShortArray* self, int newCapacity);  void spShortArray_add(spShortArray* self, short value);  void spShortArray_addAll(spShortArray* self, spShortArray* other);  void spShortArray_addAllValues(spShortArray* self, short* values, int offset, int count);  void spShortArray_removeAt(spShortArray* self, int index);  int spShortArray_contains(spShortArray* self, short value);  short spShortArray_pop(spShortArray* self);  short spShortArray_peek(spShortArray* self);
typedef struct spUnsignedShortArray { int size; int capacity; unsigned short* items; } spUnsignedShortArray;  spUnsignedShortArray* spUnsignedShortArray_create(int initialCapacity);  void spUnsignedShortArray_dispose(spUnsignedShortArray* self);  void spUnsignedShortArray_clear(spUnsignedShortArray* self);  spUnsignedShortArray* spUnsignedShortArray_setSize(spUnsignedShortArray* self, int newSize);  void spUnsignedShortArray_ensureCapacity(spUnsignedShortArray* self, int newCapacity);  void spUnsignedShortArray_add(spUnsignedShortArray* self, unsigned short value);  void spUnsignedShortArray_addAll(spUnsignedShortArray* self, spUnsignedShortArray* other);  void spUnsignedShortArray_addAllValues(spUnsignedShortArray* self, unsigned short* values, int offset, int count);  void spUnsignedShortArray_removeAt(spUnsignedShortArray* self, int index);  int spUnsignedShortArray_contains(spUnsignedShortArray* self, unsigned short value);  unsigned short spUnsignedShortArray_pop(spUnsignedShortArray* self);  unsigned short spUnsignedShortArray_peek(spUnsignedShortArray* self);
typedef struct spArrayFloatArray { int size; int capacity; spFloatArray** items; } spArrayFloatArray;  spArrayFloatArray* spArrayFloatArray_create(int initialCapacity);  void spArrayFloatArray_dispose(spArrayFloatArray* self);  void spArrayFloatArray_clear(spArrayFloatArray* self);  spArrayFloatArray* spArrayFloatArray_setSize(spArrayFloatArray* self, int newSize);  void spArrayFloatArray_ensureCapacity(spArrayFloatArray* self, int newCapacity);  void spArrayFloatArray_add(spArrayFloatArray* self, spFloatArray* value);  void spArrayFloatArray_addAll(spArrayFloatArray* self, spArrayFloatArray* other);  void spArrayFloatArray_addAllValues(spArrayFloatArray* self, spFloatArray** values, int offset, int count);  void spArrayFloatArray_removeAt(spArrayFloatArray* self, int index);  int spArrayFloatArray_contains(spArrayFloatArray* self, spFloatArray* value);  spFloatArray* spArrayFloatArray_pop(spArrayFloatArray* self);  spFloatArray* spArrayFloatArray_peek(spArrayFloatArray* self);
typedef struct spArrayShortArray { int size; int capacity; spShortArray** items; } spArrayShortArray;  spArrayShortArray* spArrayShortArray_create(int initialCapacity);  void spArrayShortArray_dispose(spArrayShortArray* self);  void spArrayShortArray_clear(spArrayShortArray* self);  spArrayShortArray* spArrayShortArray_setSize(spArrayShortArray* self, int newSize);  void spArrayShortArray_ensureCapacity(spArrayShortArray* self, int newCapacity);  void spArrayShortArray_add(spArrayShortArray* self, spShortArray* value);  void spArrayShortArray_addAll(spArrayShortArray* self, spArrayShortArray* other);  void spArrayShortArray_addAllValues(spArrayShortArray* self, spShortArray** values, int offset, int count);  void spArrayShortArray_removeAt(spArrayShortArray* self, int index);  int spArrayShortArray_contains(spArrayShortArray* self, spShortArray* value);  spShortArray* spArrayShortArray_pop(spArrayShortArray* self);  spShortArray* spArrayShortArray_peek(spArrayShortArray* self);
struct spSkeleton;
typedef struct spBoneDataArray { int size; int capacity; spBoneData** items; } spBoneDataArray;  spBoneDataArray* spBoneDataArray_create(int initialCapacity);  void spBoneDataArray_dispose(spBoneDataArray* self);  void spBoneDataArray_clear(spBoneDataArray* self);  spBoneDataArray* spBoneDataArray_setSize(spBoneDataArray* self, int newSize);  void spBoneDataArray_ensureCapacity(spBoneDataArray* self, int newCapacity);  void spBoneDataArray_add(spBoneDataArray* self, spBoneData* value);  void spBoneDataArray_addAll(spBoneDataArray* self, spBoneDataArray* other);  void spBoneDataArray_addAllValues(spBoneDataArray* self, spBoneData** values, int offset, int count);  void spBoneDataArray_removeAt(spBoneDataArray* self, int index);  int spBoneDataArray_contains(spBoneDataArray* self, spBoneData* value);  spBoneData* spBoneDataArray_pop(spBoneDataArray* self);  spBoneData* spBoneDataArray_peek(spBoneDataArray* self);
typedef struct spIkConstraintDataArray { int size; int capacity; spIkConstraintData** items; } spIkConstraintDataArray;  spIkConstraintDataArray* spIkConstraintDataArray_create(int initialCapacity);  void spIkConstraintDataArray_dispose(spIkConstraintDataArray* self);  void spIkConstraintDataArray_clear(spIkConstraintDataArray* self);  spIkConstraintDataArray* spIkConstraintDataArray_setSize(spIkConstraintDataArray* self, int newSize);  void spIkConstraintDataArray_ensureCapacity(spIkConstraintDataArray* self, int newCapacity);  void spIkConstraintDataArray_add(spIkConstraintDataArray* self, spIkConstraintData* value);  void spIkConstraintDataArray_addAll(spIkConstraintDataArray* self, spIkConstraintDataArray* other);  void spIkConstraintDataArray_addAllValues(spIkConstraintDataArray* self, spIkConstraintData** values, int offset, int count);  void spIkConstraintDataArray_removeAt(spIkConstraintDataArray* self, int index);  int spIkConstraintDataArray_contains(spIkConstraintDataArray* self, spIkConstraintData* value);  spIkConstraintData* spIkConstraintDataArray_pop(spIkConstraintDataArray* self);  spIkConstraintData* spIkConstraintDataArray_peek(spIkConstraintDataArray* self);
typedef struct spTransformConstraintDataArray { int size; int capacity; spTransformConstraintData** items; } spTransformConstraintDataArray;  spTransformConstraintDataArray* spTransformConstraintDataArray_create(int initialCapacity);  void spTransformConstraintDataArray_dispose(spTransformConstraintDataArray* self);  void spTransformConstraintDataArray_clear(spTransformConstraintDataArray* self);  spTransformConstraintDataArray* spTransformConstraintDataArray_setSize(spTransformConstraintDataArray* self, int newSize);  void spTransformConstraintDataArray_ensureCapacity(spTransformConstraintDataArray* self, int newCapacity);  void spTransformConstraintDataArray_add(spTransformConstraintDataArray* self, spTransformConstraintData* value);  void spTransformConstraintDataArray_addAll(spTransformConstraintDataArray* self, spTransformConstraintDataArray* other);  void spTransformConstraintDataArray_addAllValues(spTransformConstraintDataArray* self, spTransformConstraintData** values, int offset, int count);  void spTransformConstraintDataArray_removeAt(spTransformConstraintDataArray* self, int index);  int spTransformConstraintDataArray_contains(spTransformConstraintDataArray* self, spTransformConstraintData* value);  spTransformConstraintData* spTransformConstraintDataArray_pop(spTransformConstraintDataArray* self);  spTransformConstraintData* spTransformConstraintDataArray_peek(spTransformConstraintDataArray* self);
typedef struct spPathConstraintDataArray { int size; int capacity; spPathConstraintData** items; } spPathConstraintDataArray;  spPathConstraintDataArray* spPathConstraintDataArray_create(int initialCapacity);  void spPathConstraintDataArray_dispose(spPathConstraintDataArray* self);  void spPathConstraintDataArray_clear(spPathConstraintDataArray* self);  spPathConstraintDataArray* spPathConstraintDataArray_setSize(spPathConstraintDataArray* self, int newSize);  void spPathConstraintDataArray_ensureCapacity(spPathConstraintDataArray* self, int newCapacity);  void spPathConstraintDataArray_add(spPathConstraintDataArray* self, spPathConstraintData* value);  void spPathConstraintDataArray_addAll(spPathConstraintDataArray* self, spPathConstraintDataArray* other);  void spPathConstraintDataArray_addAllValues(spPathConstraintDataArray* self, spPathConstraintData** values, int offset, int count);  void spPathConstraintDataArray_removeAt(spPathConstraintDataArray* self, int index);  int spPathConstraintDataArray_contains(spPathConstraintDataArray* self, spPathConstraintData* value);  spPathConstraintData* spPathConstraintDataArray_pop(spPathConstraintDataArray* self);  spPathConstraintData* spPathConstraintDataArray_peek(spPathConstraintDataArray* self);
typedef struct spSkin {
	const char* const name;
	spBoneDataArray* bones;
	spIkConstraintDataArray* ikConstraints;
	spTransformConstraintDataArray* transformConstraints;
	spPathConstraintDataArray* pathConstraints;
} spSkin;
typedef struct _Entry _Entry;
typedef struct _Entry spSkinEntry;
struct _Entry {
	int slotIndex;
	const char* name;
	spAttachment* attachment;
	_Entry* next;
};
typedef struct _SkinHashTableEntry _SkinHashTableEntry;
struct _SkinHashTableEntry {
	_Entry* entry;
	_SkinHashTableEntry* next;
};
typedef struct {
	spSkin super;
	_Entry* entries; 
	_SkinHashTableEntry* entriesHashTable[100]; 
} _spSkin;
 spSkin* spSkin_create (const char* name);
 void spSkin_dispose (spSkin* self);
 void spSkin_setAttachment (spSkin* self, int slotIndex, const char* name, spAttachment* attachment);
 spAttachment* spSkin_getAttachment (const spSkin* self, int slotIndex, const char* name);
 const char* spSkin_getAttachmentName (const spSkin* self, int slotIndex, int attachmentIndex);
 void spSkin_attachAll (const spSkin* self, struct spSkeleton* skeleton, const spSkin* oldspSkin);
 void spSkin_addSkin(spSkin* self, const spSkin* other);
 void spSkin_copySkin(spSkin* self, const spSkin* other);
 spSkinEntry* spSkin_getAttachments(const spSkin* self);
 void spSkin_clear(spSkin* self);
typedef struct spSkeletonData {
	const char* version;
	const char* hash;
	float x, y, width, height;
	int stringsCount;
	char** strings;
	int bonesCount;
	spBoneData** bones;
	int slotsCount;
	spSlotData** slots;
	int skinsCount;
	spSkin** skins;
	spSkin* defaultSkin;
	int eventsCount;
	spEventData** events;
	int animationsCount;
	spAnimation** animations;
	int ikConstraintsCount;
	spIkConstraintData** ikConstraints;
	int transformConstraintsCount;
	spTransformConstraintData** transformConstraints;
	int pathConstraintsCount;
	spPathConstraintData** pathConstraints;
} spSkeletonData;
 spSkeletonData* spSkeletonData_create ();
 void spSkeletonData_dispose (spSkeletonData* self);
 spBoneData* spSkeletonData_findBone (const spSkeletonData* self, const char* boneName);
 int spSkeletonData_findBoneIndex (const spSkeletonData* self, const char* boneName);
 spSlotData* spSkeletonData_findSlot (const spSkeletonData* self, const char* slotName);
 int spSkeletonData_findSlotIndex (const spSkeletonData* self, const char* slotName);
 spSkin* spSkeletonData_findSkin (const spSkeletonData* self, const char* skinName);
 spEventData* spSkeletonData_findEvent (const spSkeletonData* self, const char* eventName);
 spAnimation* spSkeletonData_findAnimation (const spSkeletonData* self, const char* animationName);
 spIkConstraintData* spSkeletonData_findIkConstraint (const spSkeletonData* self, const char* constraintName);
 spTransformConstraintData* spSkeletonData_findTransformConstraint (const spSkeletonData* self, const char* constraintName);
 spPathConstraintData* spSkeletonData_findPathConstraint (const spSkeletonData* self, const char* constraintName);
typedef struct spAnimationStateData {
	spSkeletonData* const skeletonData;
	float defaultMix;
	const void* const entries;
} spAnimationStateData;
 spAnimationStateData* spAnimationStateData_create (spSkeletonData* skeletonData);
 void spAnimationStateData_dispose (spAnimationStateData* self);
 void spAnimationStateData_setMixByName (spAnimationStateData* self, const char* fromName, const char* toName, float duration);
 void spAnimationStateData_setMix (spAnimationStateData* self, spAnimation* from, spAnimation* to, float duration);
 float spAnimationStateData_getMix (spAnimationStateData* self, spAnimation* from, spAnimation* to);
typedef enum {
	SP_ANIMATION_START, SP_ANIMATION_INTERRUPT, SP_ANIMATION_END, SP_ANIMATION_COMPLETE, SP_ANIMATION_DISPOSE, SP_ANIMATION_EVENT
} spEventType;
typedef struct spAnimationState spAnimationState;
typedef struct spTrackEntry spTrackEntry;
typedef void (*spAnimationStateListener) (spAnimationState* state, spEventType type, spTrackEntry* entry, spEvent* event);
typedef struct spTrackEntryArray { int size; int capacity; spTrackEntry** items; } spTrackEntryArray;  spTrackEntryArray* spTrackEntryArray_create(int initialCapacity);  void spTrackEntryArray_dispose(spTrackEntryArray* self);  void spTrackEntryArray_clear(spTrackEntryArray* self);  spTrackEntryArray* spTrackEntryArray_setSize(spTrackEntryArray* self, int newSize);  void spTrackEntryArray_ensureCapacity(spTrackEntryArray* self, int newCapacity);  void spTrackEntryArray_add(spTrackEntryArray* self, spTrackEntry* value);  void spTrackEntryArray_addAll(spTrackEntryArray* self, spTrackEntryArray* other);  void spTrackEntryArray_addAllValues(spTrackEntryArray* self, spTrackEntry** values, int offset, int count);  void spTrackEntryArray_removeAt(spTrackEntryArray* self, int index);  int spTrackEntryArray_contains(spTrackEntryArray* self, spTrackEntry* value);  spTrackEntry* spTrackEntryArray_pop(spTrackEntryArray* self);  spTrackEntry* spTrackEntryArray_peek(spTrackEntryArray* self);
struct spTrackEntry {
	spAnimation* animation;
	spTrackEntry* next;
	spTrackEntry* mixingFrom;
	spTrackEntry* mixingTo;
	spAnimationStateListener listener;
	int trackIndex;
	int  loop;
	int  holdPrevious;
	float eventThreshold, attachmentThreshold, drawOrderThreshold;
	float animationStart, animationEnd, animationLast, nextAnimationLast;
	float delay, trackTime, trackLast, nextTrackLast, trackEnd, timeScale;
	float alpha, mixTime, mixDuration, interruptAlpha, totalAlpha;
	spMixBlend mixBlend;
	spIntArray* timelineMode;
	spTrackEntryArray* timelineHoldMix;
	float* timelinesRotation;
	int timelinesRotationCount;
	void* rendererObject;
	void* userData;
};
struct spAnimationState {
	spAnimationStateData* const data;
	int tracksCount;
	spTrackEntry** tracks;
	spAnimationStateListener listener;
	float timeScale;
	void* rendererObject;
	void* userData;
    int unkeyedState;
};
 spAnimationState* spAnimationState_create (spAnimationStateData* data);
 void spAnimationState_dispose (spAnimationState* self);
 void spAnimationState_update (spAnimationState* self, float delta);
 int  spAnimationState_apply (spAnimationState* self, struct spSkeleton* skeleton);
 void spAnimationState_clearTracks (spAnimationState* self);
 void spAnimationState_clearTrack (spAnimationState* self, int trackIndex);
 spTrackEntry* spAnimationState_setAnimationByName (spAnimationState* self, int trackIndex, const char* animationName,
		int loop);
 spTrackEntry* spAnimationState_setAnimation (spAnimationState* self, int trackIndex, spAnimation* animation, int loop);
 spTrackEntry* spAnimationState_addAnimationByName (spAnimationState* self, int trackIndex, const char* animationName,
		int loop, float delay);
 spTrackEntry* spAnimationState_addAnimation (spAnimationState* self, int trackIndex, spAnimation* animation, int loop,
		float delay);
 spTrackEntry* spAnimationState_setEmptyAnimation(spAnimationState* self, int trackIndex, float mixDuration);
 spTrackEntry* spAnimationState_addEmptyAnimation(spAnimationState* self, int trackIndex, float mixDuration, float delay);
 void spAnimationState_setEmptyAnimations(spAnimationState* self, float mixDuration);
 spTrackEntry* spAnimationState_getCurrent (spAnimationState* self, int trackIndex);
 void spAnimationState_clearListenerNotifications(spAnimationState* self);
 float spTrackEntry_getAnimationTime (spTrackEntry* entry);
 void spAnimationState_disposeStatics ();
typedef struct spAtlas spAtlas;
typedef enum {
	SP_ATLAS_UNKNOWN_FORMAT,
	SP_ATLAS_ALPHA,
	SP_ATLAS_INTENSITY,
	SP_ATLAS_LUMINANCE_ALPHA,
	SP_ATLAS_RGB565,
	SP_ATLAS_RGBA4444,
	SP_ATLAS_RGB888,
	SP_ATLAS_RGBA8888
} spAtlasFormat;
typedef enum {
	SP_ATLAS_UNKNOWN_FILTER,
	SP_ATLAS_NEAREST,
	SP_ATLAS_LINEAR,
	SP_ATLAS_MIPMAP,
	SP_ATLAS_MIPMAP_NEAREST_NEAREST,
	SP_ATLAS_MIPMAP_LINEAR_NEAREST,
	SP_ATLAS_MIPMAP_NEAREST_LINEAR,
	SP_ATLAS_MIPMAP_LINEAR_LINEAR
} spAtlasFilter;
typedef enum {
	SP_ATLAS_MIRROREDREPEAT,
	SP_ATLAS_CLAMPTOEDGE,
	SP_ATLAS_REPEAT
} spAtlasWrap;
typedef struct spAtlasPage spAtlasPage;
struct spAtlasPage {
	const spAtlas* atlas;
	const char* name;
	spAtlasFormat format;
	spAtlasFilter minFilter, magFilter;
	spAtlasWrap uWrap, vWrap;
	void* rendererObject;
	int width, height;
	spAtlasPage* next;
};
 spAtlasPage* spAtlasPage_create (spAtlas* atlas, const char* name);
 void spAtlasPage_dispose (spAtlasPage* self);
typedef struct spAtlasRegion spAtlasRegion;
struct spAtlasRegion {
	const char* name;
	int x, y, width, height;
	float u, v, u2, v2;
	int offsetX, offsetY;
	int originalWidth, originalHeight;
	int index;
	int rotate;
	int degrees;
	int flip;
	int* splits;
	int* pads;
	spAtlasPage* page;
	spAtlasRegion* next;
};
 spAtlasRegion* spAtlasRegion_create ();
 void spAtlasRegion_dispose (spAtlasRegion* self);
struct spAtlas {
	spAtlasPage* pages;
	spAtlasRegion* regions;
	void* rendererObject;
};
 spAtlas* spAtlas_create (const char* data, int length, const char* dir, void* rendererObject);
 spAtlas* spAtlas_createFromFile (const char* path, void* rendererObject);
 void spAtlas_dispose (spAtlas* atlas);
 spAtlasRegion* spAtlas_findRegion (const spAtlas* self, const char* name);
typedef struct spAttachmentLoader {
	const char* error1;
	const char* error2;
	const void* const vtable;
} spAttachmentLoader;
 void spAttachmentLoader_dispose (spAttachmentLoader* self);
 spAttachment* spAttachmentLoader_createAttachment (spAttachmentLoader* self, spSkin* skin, spAttachmentType type, const char* name,
		const char* path);
 void spAttachmentLoader_configureAttachment (spAttachmentLoader* self, spAttachment* attachment);
 void spAttachmentLoader_disposeAttachment (spAttachmentLoader* self, spAttachment* attachment);
typedef struct spAtlasAttachmentLoader {
	spAttachmentLoader super;
	spAtlas* atlas;
} spAtlasAttachmentLoader;
 spAtlasAttachmentLoader* spAtlasAttachmentLoader_create (spAtlas* atlas);
struct spSkeleton;
typedef struct spBone spBone;
struct spBone {
	spBoneData* const data;
	struct spSkeleton* const skeleton;
	spBone* const parent;
	int childrenCount;
	spBone** const children;
	float x, y, rotation, scaleX, scaleY, shearX, shearY;
	float ax, ay, arotation, ascaleX, ascaleY, ashearX, ashearY;
	int  appliedValid;
	float const a, b, worldX;
	float const c, d, worldY;
	int sorted;
	int active;
};
 void spBone_setYDown (int yDown);
 int spBone_isYDown ();
 spBone* spBone_create (spBoneData* data, struct spSkeleton* skeleton, spBone* parent);
 void spBone_dispose (spBone* self);
 void spBone_setToSetupPose (spBone* self);
 void spBone_updateWorldTransform (spBone* self);
 void spBone_updateWorldTransformWith (spBone* self, float x, float y, float rotation, float scaleX, float scaleY, float shearX, float shearY);
 float spBone_getWorldRotationX (spBone* self);
 float spBone_getWorldRotationY (spBone* self);
 float spBone_getWorldScaleX (spBone* self);
 float spBone_getWorldScaleY (spBone* self);
 void spBone_updateAppliedTransform (spBone* self);
 void spBone_worldToLocal (spBone* self, float worldX, float worldY, float* localX, float* localY);
 void spBone_localToWorld (spBone* self, float localX, float localY, float* worldX, float* worldY);
 float spBone_worldToLocalRotation (spBone* self, float worldRotation);
 float spBone_localToWorldRotation (spBone* self, float localRotation);
 void spBone_rotateWorld (spBone* self, float degrees);
typedef struct spSlot {
	spSlotData* const data;
	spBone* const bone;
	spColor color;
	spColor* darkColor;
	spAttachment* attachment;
	int attachmentState;
	int deformCapacity;
	int deformCount;
	float* deform;
} spSlot;
 spSlot* spSlot_create (spSlotData* data, spBone* bone);
 void spSlot_dispose (spSlot* self);
 void spSlot_setAttachment (spSlot* self, spAttachment* attachment);
 void spSlot_setAttachmentTime (spSlot* self, float time);
 float spSlot_getAttachmentTime (const spSlot* self);
 void spSlot_setToSetupPose (spSlot* self);
typedef struct spRegionAttachment {
	spAttachment super;
	const char* path;
	float x, y, scaleX, scaleY, rotation, width, height;
	spColor color;
	void* rendererObject;
	int regionOffsetX, regionOffsetY; 
	int regionWidth, regionHeight; 
	int regionOriginalWidth, regionOriginalHeight; 
	float offset[8];
	float uvs[8];
} spRegionAttachment;
 spRegionAttachment* spRegionAttachment_create (const char* name);
 void spRegionAttachment_setUVs (spRegionAttachment* self, float u, float v, float u2, float v2, int rotate);
 void spRegionAttachment_updateOffset (spRegionAttachment* self);
 void spRegionAttachment_computeWorldVertices (spRegionAttachment* self, spBone* bone, float* vertices, int offset, int stride);
typedef struct spVertexAttachment spVertexAttachment;
struct spVertexAttachment {
	spAttachment super;
	int bonesCount;
	int* bones;
	int verticesCount;
	float* vertices;
	int worldVerticesLength;
	spVertexAttachment* deformAttachment;
	int id;
};
 void spVertexAttachment_computeWorldVertices (spVertexAttachment* self, spSlot* slot, int start, int count, float* worldVertices, int offset, int stride);
void spVertexAttachment_copyTo(spVertexAttachment* self, spVertexAttachment* other);
typedef struct spMeshAttachment spMeshAttachment;
struct spMeshAttachment {
	spVertexAttachment super;
	void* rendererObject;
	int regionOffsetX, regionOffsetY; 
	int regionWidth, regionHeight; 
	int regionOriginalWidth, regionOriginalHeight; 
	float regionU, regionV, regionU2, regionV2;
	int regionRotate;
	int regionDegrees;
	const char* path;
	float* regionUVs;
	float* uvs;
	int trianglesCount;
	unsigned short* triangles;
	spColor color;
	int hullLength;
	spMeshAttachment* const parentMesh;
	
	int edgesCount;
	int* edges;
	float width, height;
};
 spMeshAttachment* spMeshAttachment_create (const char* name);
 void spMeshAttachment_updateUVs (spMeshAttachment* self);
 void spMeshAttachment_setParentMesh (spMeshAttachment* self, spMeshAttachment* parentMesh);
 spMeshAttachment* spMeshAttachment_newLinkedMesh (spMeshAttachment* self);
typedef struct spBoundingBoxAttachment {
	spVertexAttachment super;
} spBoundingBoxAttachment;
 spBoundingBoxAttachment* spBoundingBoxAttachment_create (const char* name);
typedef struct spClippingAttachment {
	spVertexAttachment super;
	spSlotData* endSlot;
} spClippingAttachment;
 void _spClippingAttachment_dispose(spAttachment* self);
 spClippingAttachment* spClippingAttachment_create (const char* name);
typedef struct spPointAttachment {
	spAttachment super;
	float x, y, rotation;
	spColor color;
} spPointAttachment;
 spPointAttachment* spPointAttachment_create (const char* name);
 void spPointAttachment_computeWorldPosition (spPointAttachment* self, spBone* bone, float* x, float* y);
 float spPointAttachment_computeWorldRotation (spPointAttachment* self, spBone* bone);
struct spSkeleton;
typedef struct spIkConstraint {
	spIkConstraintData* const data;
	int bonesCount;
	spBone** bones;
	spBone* target;
	int bendDirection;
	int  compress;
	int  stretch;
	float mix;
	float softness;
	int  active;
} spIkConstraint;
 spIkConstraint* spIkConstraint_create (spIkConstraintData* data, const struct spSkeleton* skeleton);
 void spIkConstraint_dispose (spIkConstraint* self);
 void spIkConstraint_apply (spIkConstraint* self);
 void spIkConstraint_apply1 (spBone* bone, float targetX, float targetY, int  compress, int  stretch, int  uniform, float alpha);
 void spIkConstraint_apply2 (spBone* parent, spBone* child, float targetX, float targetY, int bendDirection, int  stretch, float softness, float alpha);
struct spSkeleton;
typedef struct spTransformConstraint {
	spTransformConstraintData* const data;
	int bonesCount;
	spBone** const bones;
	spBone* target;
	float rotateMix, translateMix, scaleMix, shearMix;
	int  active;
} spTransformConstraint;
 spTransformConstraint* spTransformConstraint_create (spTransformConstraintData* data, const struct spSkeleton* skeleton);
 void spTransformConstraint_dispose (spTransformConstraint* self);
 void spTransformConstraint_apply (spTransformConstraint* self);
typedef struct spPathAttachment {
	spVertexAttachment super;
	int lengthsLength;
	float* lengths;
	int closed, constantSpeed;
} spPathAttachment;
 spPathAttachment* spPathAttachment_create (const char* name);
struct spSkeleton;
typedef struct spPathConstraint {
	spPathConstraintData* const data;
	int bonesCount;
	spBone** const bones;
	spSlot* target;
	float position, spacing, rotateMix, translateMix;
	int spacesCount;
	float* spaces;
	int positionsCount;
	float* positions;
	int worldCount;
	float* world;
	int curvesCount;
	float* curves;
	int lengthsCount;
	float* lengths;
	float segments[10];
	int  active;
} spPathConstraint;
 spPathConstraint* spPathConstraint_create (spPathConstraintData* data, const struct spSkeleton* skeleton);
 void spPathConstraint_dispose (spPathConstraint* self);
 void spPathConstraint_apply (spPathConstraint* self);
 float* spPathConstraint_computeWorldPositions(spPathConstraint* self, spPathAttachment* path, int spacesCount, int tangents, int percentPosition, int percentSpacing);
typedef struct spSkeleton {
	spSkeletonData* const data;
	int bonesCount;
	spBone** bones;
	spBone* const root;
	int slotsCount;
	spSlot** slots;
	spSlot** drawOrder;
	int ikConstraintsCount;
	spIkConstraint** ikConstraints;
	int transformConstraintsCount;
	spTransformConstraint** transformConstraints;
	int pathConstraintsCount;
	spPathConstraint** pathConstraints;
	spSkin* const skin;
	spColor color;
	float time;
	float scaleX, scaleY;
	float x, y;
} spSkeleton;
 spSkeleton* spSkeleton_create (spSkeletonData* data);
 void spSkeleton_dispose (spSkeleton* self);
 void spSkeleton_updateCache (spSkeleton* self);
 void spSkeleton_updateWorldTransform (const spSkeleton* self);
 void spSkeleton_setToSetupPose (const spSkeleton* self);
 void spSkeleton_setBonesToSetupPose (const spSkeleton* self);
 void spSkeleton_setSlotsToSetupPose (const spSkeleton* self);
 spBone* spSkeleton_findBone (const spSkeleton* self, const char* boneName);
 int spSkeleton_findBoneIndex (const spSkeleton* self, const char* boneName);
 spSlot* spSkeleton_findSlot (const spSkeleton* self, const char* slotName);
 int spSkeleton_findSlotIndex (const spSkeleton* self, const char* slotName);
 void spSkeleton_setSkin (spSkeleton* self, spSkin* skin);
 int spSkeleton_setSkinByName (spSkeleton* self, const char* skinName);
 spAttachment* spSkeleton_getAttachmentForSlotName (const spSkeleton* self, const char* slotName, const char* attachmentName);
 spAttachment* spSkeleton_getAttachmentForSlotIndex (const spSkeleton* self, int slotIndex, const char* attachmentName);
 int spSkeleton_setAttachment (spSkeleton* self, const char* slotName, const char* attachmentName);
 spIkConstraint* spSkeleton_findIkConstraint (const spSkeleton* self, const char* constraintName);
 spTransformConstraint* spSkeleton_findTransformConstraint (const spSkeleton* self, const char* constraintName);
 spPathConstraint* spSkeleton_findPathConstraint (const spSkeleton* self, const char* constraintName);
 void spSkeleton_update (spSkeleton* self, float deltaTime);
typedef struct spPolygon {
	float* const vertices;
	int count;
	int capacity;
} spPolygon;
 spPolygon* spPolygon_create (int capacity);
 void spPolygon_dispose (spPolygon* self);
int spPolygon_containsPoint (spPolygon* polygon, float x, float y);
int spPolygon_intersectsSegment (spPolygon* polygon, float x1, float y1, float x2, float y2);
typedef struct spSkeletonBounds {
	int count;
	spBoundingBoxAttachment** boundingBoxes;
	spPolygon** polygons;
	float minX, minY, maxX, maxY;
} spSkeletonBounds;
 spSkeletonBounds* spSkeletonBounds_create ();
 void spSkeletonBounds_dispose (spSkeletonBounds* self);
 void spSkeletonBounds_update (spSkeletonBounds* self, spSkeleton* skeleton,int updateAabb);
int spSkeletonBounds_aabbContainsPoint (spSkeletonBounds* self, float x, float y);
int spSkeletonBounds_aabbIntersectsSegment (spSkeletonBounds* self, float x1, float y1, float x2, float y2);
int spSkeletonBounds_aabbIntersectsSkeleton (spSkeletonBounds* self, spSkeletonBounds* bounds);
 spBoundingBoxAttachment* spSkeletonBounds_containsPoint (spSkeletonBounds* self, float x, float y);
 spBoundingBoxAttachment* spSkeletonBounds_intersectsSegment (spSkeletonBounds* self, float x1, float y1, float x2, float y2);
 spPolygon* spSkeletonBounds_getPolygon (spSkeletonBounds* self, spBoundingBoxAttachment* boundingBox);
struct spAtlasAttachmentLoader;
typedef struct spSkeletonBinary {
	float scale;
	spAttachmentLoader* attachmentLoader;
	const char* const error;
} spSkeletonBinary;
 spSkeletonBinary* spSkeletonBinary_createWithLoader (spAttachmentLoader* attachmentLoader);
 spSkeletonBinary* spSkeletonBinary_create (spAtlas* atlas);
 void spSkeletonBinary_dispose (spSkeletonBinary* self);
 spSkeletonData* spSkeletonBinary_readSkeletonData (spSkeletonBinary* self, const unsigned char* binary, const int length);
 spSkeletonData* spSkeletonBinary_readSkeletonDataFile (spSkeletonBinary* self, const char* path);
struct spAtlasAttachmentLoader;
typedef struct spSkeletonJson {
	float scale;
	spAttachmentLoader* attachmentLoader;
	const char* const error;
} spSkeletonJson;
 spSkeletonJson* spSkeletonJson_createWithLoader (spAttachmentLoader* attachmentLoader);
 spSkeletonJson* spSkeletonJson_create (spAtlas* atlas);
 void spSkeletonJson_dispose (spSkeletonJson* self);
 spSkeletonData* spSkeletonJson_readSkeletonData (spSkeletonJson* self, const char* json);
 spSkeletonData* spSkeletonJson_readSkeletonDataFile (spSkeletonJson* self, const char* path);
typedef struct spTriangulator {
	spArrayFloatArray* convexPolygons;
	spArrayShortArray* convexPolygonsIndices;
	spShortArray* indicesArray;
	spIntArray* isConcaveArray;
	spShortArray* triangles;
	spArrayFloatArray* polygonPool;
	spArrayShortArray* polygonIndicesPool;
} spTriangulator;
 spTriangulator* spTriangulator_create();
 spShortArray* spTriangulator_triangulate(spTriangulator* self, spFloatArray* verticesArray);
 spArrayFloatArray* spTriangulator_decompose(spTriangulator* self, spFloatArray* verticesArray, spShortArray* triangles);
 void spTriangulator_dispose(spTriangulator* self);
typedef struct spSkeletonClipping {
	spTriangulator* triangulator;
	spFloatArray* clippingPolygon;
	spFloatArray* clipOutput;
	spFloatArray* clippedVertices;
	spFloatArray* clippedUVs;
	spUnsignedShortArray* clippedTriangles;
	spFloatArray* scratch;
	spClippingAttachment* clipAttachment;
	spArrayFloatArray* clippingPolygons;
} spSkeletonClipping;
 spSkeletonClipping* spSkeletonClipping_create();
 int spSkeletonClipping_clipStart(spSkeletonClipping* self, spSlot* slot, spClippingAttachment* clip);
 void spSkeletonClipping_clipEnd(spSkeletonClipping* self, spSlot* slot);
 void spSkeletonClipping_clipEnd2(spSkeletonClipping* self);
 int  spSkeletonClipping_isClipping(spSkeletonClipping* self);
 void spSkeletonClipping_clipTriangles(spSkeletonClipping* self, float* vertices, int verticesLength, unsigned short* triangles, int trianglesLength, float* uvs, int stride);
 void spSkeletonClipping_dispose(spSkeletonClipping* self);
struct spVertexEffect;
typedef void (*spVertexEffectBegin)(struct spVertexEffect *self, spSkeleton *skeleton);
typedef void (*spVertexEffectTransform)(struct spVertexEffect *self, float *x, float *y, float *u, float *v,
	spColor *light, spColor *dark);
typedef void (*spVertexEffectEnd)(struct spVertexEffect *self);
typedef struct spVertexEffect {
	spVertexEffectBegin begin;
	spVertexEffectTransform transform;
	spVertexEffectEnd end;
} spVertexEffect;
typedef struct spJitterVertexEffect {
	spVertexEffect super;
	float jitterX;
	float jitterY;
} spJitterVertexEffect;
typedef struct spSwirlVertexEffect {
	spVertexEffect super;
	float centerX;
	float centerY;
	float radius;
	float angle;
	float worldX;
	float worldY;
} spSwirlVertexEffect;
typedef struct HitTestRecorder_t {
	uint64_t count;
	void** list;
	uint64_t capacity;
} HitTestRecorder;
typedef struct eventRecorderAtom_t {
	spEventType type;
	spTrackEntry* entry;
	spEvent event;
	struct eventRecorderAtom_t* next;
} eventRecorderAtom;
 spJitterVertexEffect *spJitterVertexEffect_create(float jitterX, float jitterY);
 void spJitterVertexEffect_dispose(spJitterVertexEffect *effect);
 spSwirlVertexEffect *spSwirlVertexEffect_create(float radius);
 void spSwirlVertexEffect_dispose(spSwirlVertexEffect *effect);
 void drawSkeleton(spSkeleton* skeleton, bool PMA);
 int spSkeleton_containsPoint(spSkeleton* self, float px, float py, HitTestRecorder* re);
 void spSkeleton_getAabbBox(spSkeleton* self, Rectangle* rect);
 void eventListenerFunc(spAnimationState* state, spEventType type, spTrackEntry* entry, spEvent* event);
 void releaseAllEvents(spAnimationState* state);
]]
return hdtLoadFFI('hdt-raylib-spine.dll')
