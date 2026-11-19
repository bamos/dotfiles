// Publish text, rich documents, and image pixels as one clipboard item.
#import <AppKit/AppKit.h>

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSError *error = nil;
    NSData *input = [[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile];
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:input options:0 error:&error];
    if (![payload isKindOfClass:[NSDictionary class]] ||
        ![payload[@"html"] isKindOfClass:[NSString class]] ||
        ![payload[@"plain"] isKindOfClass:[NSString class]]) return 1;
    NSData *html = [payload[@"html"] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
      initWithString:payload[@"plain"]
      attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:12]}];
    if (![payload[@"links"] isKindOfClass:[NSArray class]]) return 1;
    for (NSDictionary *link in payload[@"links"]) {
      if (![link[@"start"] isKindOfClass:[NSNumber class]] ||
          ![link[@"length"] isKindOfClass:[NSNumber class]] ||
          ![link[@"url"] isKindOfClass:[NSString class]]) return 1;
      NSUInteger start = [link[@"start"] unsignedIntegerValue];
      NSUInteger length = [link[@"length"] unsignedIntegerValue];
      if (start > text.length || length > text.length - start) return 1;
      [text addAttribute:NSLinkAttributeName value:link[@"url"] range:NSMakeRange(start, length)];
    }
    NSArray *images = payload[@"images"] ?: @[];
    if (![images isKindOfClass:[NSArray class]]) return 1;
    NSData *png = nil, *tiff = nil;
    for (NSDictionary *entry in images) {
      if (![entry[@"start"] isKindOfClass:[NSNumber class]] ||
          ![entry[@"path"] isKindOfClass:[NSString class]]) return 1;
      NSUInteger start = [entry[@"start"] unsignedIntegerValue];
      if (start >= text.length || [text.string characterAtIndex:start] != 0xfffc) return 1;
      NSData *bytes = [NSData dataWithContentsOfFile:entry[@"path"]];
      NSImage *image = [[NSImage alloc] initWithData:bytes];
      NSData *imageTIFF = [image TIFFRepresentation];
      NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:imageTIFF];
      if (!image || !bitmap) {
        fprintf(stderr, "Could not decode the copied image\n");
        return 1;
      }
      // Keep PNG bytes intact.  Besides avoiding quality loss, this lets a
      // later external paste find and reuse the same existing image file.
      NSData *imagePNG = [[[entry[@"path"] pathExtension] lowercaseString] isEqual:@"png"]
                        ? bytes : [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
      if (!imagePNG) return 1;
      if (images.count == 1 && [payload[@"imageOnly"] boolValue]) {
        png = imagePNG;
        tiff = imageTIFF;
      }
      NSFileWrapper *file = [[NSFileWrapper alloc] initRegularFileWithContents:imagePNG];
      file.preferredFilename = [NSString stringWithFormat:@"image-%lu.png", (unsigned long)start];
      NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:file];
      if ([entry[@"width"] isKindOfClass:[NSNumber class]] && [entry[@"width"] doubleValue] > 0) {
        CGFloat width = [entry[@"width"] doubleValue];
        image.size = NSMakeSize(width, width * bitmap.pixelsHigh / bitmap.pixelsWide);
        attachment.attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:image];
      }
      [text addAttribute:NSAttachmentAttributeName value:attachment range:NSMakeRange(start, 1)];
    }
    NSData *rtf = [text RTFFromRange:NSMakeRange(0, text.length) documentAttributes:@{}];
    NSData *rtfd = images.count ? [text RTFDFromRange:NSMakeRange(0, text.length) documentAttributes:@{}] : nil;
    if (!text || !rtf || (images.count && !rtfd)) {
      fprintf(stderr, "Could not encode the rich clipboard document\n");
      return 1;
    }
    if (argc == 2 && strcmp(argv[1], "--convert") == 0) {
      // Conversion-only mode lets tests inspect the native RTF without touching
      // the user's clipboard.
      NSMutableDictionary *formats = [@{@"rtf": [rtf base64EncodedStringWithOptions:0],
                                        @"html": payload[@"html"], @"text": text.string} mutableCopy];
      if (png) formats[@"png"] = [png base64EncodedStringWithOptions:0];
      if (tiff) formats[@"tiff"] = [tiff base64EncodedStringWithOptions:0];
      if (rtfd) formats[@"rtfd"] = [rtfd base64EncodedStringWithOptions:0];
      NSData *result = [NSJSONSerialization dataWithJSONObject:formats options:0 error:&error];
      [[NSFileHandle fileHandleWithStandardOutput] writeData:result];
      return 0;
    }
    BOOL selfTest = argc == 2 && strcmp(argv[1], "--self-test") == 0;
    NSPasteboard *pasteboard = selfTest ? [NSPasteboard pasteboardWithUniqueName]
                                      : [NSPasteboard generalPasteboard];
    if (selfTest) {
      [pasteboard declareTypes:@[NSPasteboardTypeString] owner:nil];
      [pasteboard setString:payload[@"expected"] forType:NSPasteboardTypeString];
    }
    // Do not overwrite another application's copy made during conversion.
    if (![payload[@"expected"] isKindOfClass:[NSString class]] ||
        ![[pasteboard stringForType:NSPasteboardTypeString] isEqual:payload[@"expected"]]) return 2;
    NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
    if (png) [item setData:png forType:NSPasteboardTypePNG];
    if (tiff) [item setData:tiff forType:NSPasteboardTypeTIFF];
    if (rtfd) [item setData:rtfd forType:NSPasteboardTypeRTFD];
    [item setData:html forType:NSPasteboardTypeHTML];
    [item setData:rtf forType:NSPasteboardTypeRTF];
    [item setString:payload[@"plain"] forType:NSPasteboardTypeString];
    [pasteboard clearContents];
    BOOL written = [pasteboard writeObjects:@[item]];
    if (selfTest && written) {
      NSAttributedString *roundTrip = [[NSAttributedString alloc]
        initWithRTF:[pasteboard dataForType:NSPasteboardTypeRTF] documentAttributes:nil];
      __block NSUInteger links = 0;
      [roundTrip enumerateAttribute:NSLinkAttributeName inRange:NSMakeRange(0, roundTrip.length)
        options:0 usingBlock:^(id value, NSRange range, BOOL *stop) { if (value) links++; }];
      NSAttributedString *richRoundTrip = rtfd ? [[NSAttributedString alloc]
        initWithRTFD:[pasteboard dataForType:NSPasteboardTypeRTFD] documentAttributes:nil] : nil;
      __block NSUInteger attachments = 0;
      [richRoundTrip enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, richRoundTrip.length)
        options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
          if ([value isKindOfClass:[NSTextAttachment class]] &&
              [[NSImage alloc] initWithData:[value fileWrapper].regularFileContents]) attachments++;
        }];
      NSBitmapImageRep *pasted = png ? [NSBitmapImageRep imageRepWithData:
        [pasteboard dataForType:NSPasteboardTypePNG]] : nil;
      NSData *result = [NSJSONSerialization dataWithJSONObject:
        @{@"plain": [pasteboard stringForType:NSPasteboardTypeString],
          @"html": @([[pasteboard dataForType:NSPasteboardTypeHTML] isEqual:html]),
          @"links": @(links), @"attachments": @(attachments),
          @"png": @((BOOL)(png && [[pasteboard dataForType:NSPasteboardTypePNG] isEqual:png])),
          @"tiff": @((BOOL)(tiff && [[pasteboard dataForType:NSPasteboardTypeTIFF] isEqual:tiff])),
          @"imageWidth": @(pasted.pixelsWide), @"imageHeight": @(pasted.pixelsHigh)}
        options:0 error:&error];
      [[NSFileHandle fileHandleWithStandardOutput] writeData:result];
      [pasteboard releaseGlobally];
    }
    return written ? 0 : 1;
  }
}
