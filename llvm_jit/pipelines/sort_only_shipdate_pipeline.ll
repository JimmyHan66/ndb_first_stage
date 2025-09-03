; ModuleID = 'sort_only_shipdate_pipeline.c'
source_filename = "sort_only_shipdate_pipeline.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.ScanHandle = type opaque
%struct.ArrowBatch = type { %struct.ArrowArray*, %struct.ArrowSchema*, i64, i32, i8* }
%struct.ArrowArray = type { i64, i64, i64, i64, i64, i8**, %struct.ArrowArray**, %struct.ArrowArray*, void (%struct.ArrowArray*)*, i8* }
%struct.ArrowSchema = type { i8*, i8*, i8*, i64, i64, %struct.ArrowSchema**, %struct.ArrowSchema*, void (%struct.ArrowSchema*)*, i8* }
%struct.ArrowColumnView = type { %struct.ArrowArray*, %struct.ArrowSchema*, i8*, i8*, i32*, i8*, i32, i32, i64, i64 }
%struct.ShipdateRowGlobal = type { i32, i32, i32 }

@.str.1 = private unnamed_addr constant [43 x i8] c"Failed to get shipdate column in batch %d\0A\00", align 1
@.str.3 = private unnamed_addr constant [45 x i8] c"Collected batch %d: %lld rows (total: %lld)\0A\00", align 1
@.str.4 = private unnamed_addr constant [32 x i8] c"\0ASorting %lld rows globally...\0A\00", align 1
@.str.6 = private unnamed_addr constant [23 x i8] c"First 5 sorted dates: \00", align 1
@.str.7 = private unnamed_addr constant [4 x i8] c"%d \00", align 1
@.str.8 = private unnamed_addr constant [6 x i8] c"NULL \00", align 1
@.str.11 = private unnamed_addr constant [19 x i8] c"Total batches: %d\0A\00", align 1
@.str.12 = private unnamed_addr constant [28 x i8] c"Total rows collected: %lld\0A\00", align 1
@.str.13 = private unnamed_addr constant [25 x i8] c"Total rows sorted: %lld\0A\00", align 1
@.str.14 = private unnamed_addr constant [23 x i8] c"Error during scan: %d\0A\00", align 1
@str = private unnamed_addr constant [40 x i8] c"=== sort_only_shipdate JIT Pipeline ===\00", align 1
@str.15 = private unnamed_addr constant [36 x i8] c"\0A=== sort_only_shipdate Results ===\00", align 1
@str.16 = private unnamed_addr constant [26 x i8] c"Global sorting completed!\00", align 1
@str.17 = private unnamed_addr constant [48 x i8] c"Failed to allocate memory for global sort array\00", align 1

; Function Attrs: nounwind uwtable
define dso_local i32 @sort_only_shipdate_pipeline_jit(%struct.ScanHandle* noundef %0) local_unnamed_addr #0 {
  %2 = alloca %struct.ArrowBatch, align 8
  %3 = alloca %struct.ArrowColumnView, align 8
  %4 = icmp eq %struct.ScanHandle* %0, null
  br i1 %4, label %144, label %5

5:                                                ; preds = %1
  %6 = bitcast %struct.ArrowBatch* %2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %6) #8
  %7 = call i32 @ndb_arrow_batch_init(%struct.ArrowBatch* noundef nonnull %2) #8
  %8 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([40 x i8], [40 x i8]* @str, i64 0, i64 0))
  %9 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #8
  %10 = icmp sgt i32 %9, 0
  br i1 %10, label %11, label %127

11:                                               ; preds = %5
  %12 = getelementptr inbounds %struct.ArrowBatch, %struct.ArrowBatch* %2, i64 0, i32 2
  %13 = bitcast %struct.ArrowColumnView* %3 to i8*
  %14 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 3
  %15 = bitcast i8** %14 to i32**
  %16 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 2
  %17 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 9
  br label %18

18:                                               ; preds = %11, %93
  %19 = phi %struct.ShipdateRowGlobal* [ null, %11 ], [ %96, %93 ]
  %20 = phi i64 [ 0, %11 ], [ %95, %93 ]
  %21 = phi i64 [ 0, %11 ], [ %94, %93 ]
  %22 = phi i32 [ 0, %11 ], [ %25, %93 ]
  br label %23

23:                                               ; preds = %18, %28
  %24 = phi i32 [ %22, %18 ], [ %25, %28 ]
  %25 = add nsw i32 %24, 1
  %26 = load i64, i64* %12, align 8, !tbaa !5
  %27 = icmp eq i64 %26, 0
  br i1 %27, label %28, label %31

28:                                               ; preds = %23
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #8
  %29 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #8
  %30 = icmp sgt i32 %29, 0
  br i1 %30, label %23, label %99, !llvm.loop !12

31:                                               ; preds = %23
  call void @llvm.lifetime.start.p0i8(i64 72, i8* nonnull %13) #8
  %32 = call i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef nonnull %2, i32 noundef 0, %struct.ArrowColumnView* noundef nonnull %3) #8
  %33 = icmp eq i32 %32, 0
  br i1 %33, label %36, label %34

34:                                               ; preds = %31
  %35 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([43 x i8], [43 x i8]* @.str.1, i64 0, i64 0), i32 noundef %25)
  br label %93, !llvm.loop !12

36:                                               ; preds = %31
  %37 = load i64, i64* %12, align 8, !tbaa !5
  %38 = add nsw i64 %37, %20
  %39 = icmp sgt i64 %38, %21
  br i1 %39, label %40, label %51

40:                                               ; preds = %36
  %41 = bitcast %struct.ShipdateRowGlobal* %19 to i8*
  %42 = mul i64 %38, 24
  %43 = call i8* @realloc(i8* noundef %41, i64 noundef %42) #8
  %44 = icmp eq i8* %43, null
  br i1 %44, label %49, label %45

45:                                               ; preds = %40
  %46 = bitcast i8* %43 to %struct.ShipdateRowGlobal*
  %47 = shl nsw i64 %38, 1
  %48 = load i64, i64* %12, align 8, !tbaa !5
  br label %51

49:                                               ; preds = %40
  %50 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([48 x i8], [48 x i8]* @str.17, i64 0, i64 0))
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #8
  call void @llvm.lifetime.end.p0i8(i64 72, i8* nonnull %13) #8
  br label %142

51:                                               ; preds = %45, %36
  %52 = phi i64 [ %48, %45 ], [ %37, %36 ]
  %53 = phi i64 [ %47, %45 ], [ %21, %36 ]
  %54 = phi %struct.ShipdateRowGlobal* [ %46, %45 ], [ %19, %36 ]
  %55 = load i32*, i32** %15, align 8, !tbaa !14
  %56 = load i8*, i8** %16, align 8, !tbaa !16
  %57 = icmp sgt i64 %52, 0
  br i1 %57, label %58, label %61

58:                                               ; preds = %51
  %59 = load i64, i64* %17, align 8, !tbaa !17
  %60 = icmp eq i8* %56, null
  br label %65

61:                                               ; preds = %82, %51
  %62 = phi i64 [ %20, %51 ], [ %88, %82 ]
  %63 = srem i32 %25, 100
  %64 = icmp eq i32 %63, 0
  br i1 %64, label %91, label %93

65:                                               ; preds = %58, %82
  %66 = phi i64 [ %20, %58 ], [ %88, %82 ]
  %67 = phi i64 [ 0, %58 ], [ %89, %82 ]
  %68 = add nsw i64 %59, %67
  br i1 %60, label %79, label %69

69:                                               ; preds = %65
  %70 = sdiv i64 %68, 8
  %71 = srem i64 %68, 8
  %72 = getelementptr inbounds i8, i8* %56, i64 %70
  %73 = load i8, i8* %72, align 1, !tbaa !18
  %74 = zext i8 %73 to i32
  %75 = trunc i64 %71 to i32
  %76 = shl nuw nsw i32 1, %75
  %77 = and i32 %76, %74
  %78 = icmp eq i32 %77, 0
  br i1 %78, label %82, label %79

79:                                               ; preds = %65, %69
  %80 = getelementptr inbounds i32, i32* %55, i64 %68
  %81 = load i32, i32* %80, align 4, !tbaa !19
  br label %82

82:                                               ; preds = %69, %79
  %83 = phi i32 [ %81, %79 ], [ 2147483647, %69 ]
  %84 = getelementptr inbounds %struct.ShipdateRowGlobal, %struct.ShipdateRowGlobal* %54, i64 %66, i32 0
  store i32 %83, i32* %84, align 4, !tbaa !20
  %85 = trunc i64 %67 to i32
  %86 = getelementptr inbounds %struct.ShipdateRowGlobal, %struct.ShipdateRowGlobal* %54, i64 %66, i32 1
  store i32 %85, i32* %86, align 4, !tbaa !22
  %87 = getelementptr inbounds %struct.ShipdateRowGlobal, %struct.ShipdateRowGlobal* %54, i64 %66, i32 2
  store i32 %25, i32* %87, align 4, !tbaa !23
  %88 = add nsw i64 %66, 1
  %89 = add nuw nsw i64 %67, 1
  %90 = icmp eq i64 %89, %52
  br i1 %90, label %61, label %65, !llvm.loop !24

91:                                               ; preds = %61
  %92 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([45 x i8], [45 x i8]* @.str.3, i64 0, i64 0), i32 noundef %25, i64 noundef %52, i64 noundef %62)
  br label %93

93:                                               ; preds = %61, %91, %34
  %94 = phi i64 [ %21, %34 ], [ %53, %91 ], [ %53, %61 ]
  %95 = phi i64 [ %20, %34 ], [ %62, %91 ], [ %62, %61 ]
  %96 = phi %struct.ShipdateRowGlobal* [ %19, %34 ], [ %54, %91 ], [ %54, %61 ]
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #8
  call void @llvm.lifetime.end.p0i8(i64 72, i8* nonnull %13) #8
  %97 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #8
  %98 = icmp sgt i32 %97, 0
  br i1 %98, label %18, label %99

99:                                               ; preds = %93, %28
  %100 = phi i64 [ %20, %28 ], [ %95, %93 ]
  %101 = phi %struct.ShipdateRowGlobal* [ %19, %28 ], [ %96, %93 ]
  %102 = phi i32 [ %29, %28 ], [ %97, %93 ]
  %103 = icmp sgt i64 %100, 0
  %104 = icmp ne %struct.ShipdateRowGlobal* %101, null
  %105 = select i1 %103, i1 %104, i1 false
  br i1 %105, label %106, label %127

106:                                              ; preds = %99
  %107 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([32 x i8], [32 x i8]* @.str.4, i64 0, i64 0), i64 noundef %100)
  %108 = bitcast %struct.ShipdateRowGlobal* %101 to i8*
  call void @pdqsort(i8* noundef nonnull %108, i64 noundef %100, i64 noundef 12, i32 (i8*, i8*)* noundef nonnull @compare_shipdate_rows_global) #8
  %109 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([26 x i8], [26 x i8]* @str.16, i64 0, i64 0))
  %110 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.6, i64 0, i64 0))
  %111 = add nsw i64 %100, -1
  %112 = call i64 @llvm.umin.i64(i64 %111, i64 4)
  br label %115

113:                                              ; preds = %124
  %114 = call i32 @putchar(i32 10)
  br label %127

115:                                              ; preds = %106, %124
  %116 = phi i64 [ 0, %106 ], [ %125, %124 ]
  %117 = getelementptr inbounds %struct.ShipdateRowGlobal, %struct.ShipdateRowGlobal* %101, i64 %116, i32 0
  %118 = load i32, i32* %117, align 4, !tbaa !20
  %119 = icmp eq i32 %118, 2147483647
  br i1 %119, label %122, label %120

120:                                              ; preds = %115
  %121 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str.7, i64 0, i64 0), i32 noundef %118)
  br label %124

122:                                              ; preds = %115
  %123 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.8, i64 0, i64 0))
  br label %124

124:                                              ; preds = %120, %122
  %125 = add nuw nsw i64 %116, 1
  %126 = icmp eq i64 %116, %112
  br i1 %126, label %113, label %115, !llvm.loop !25

127:                                              ; preds = %5, %99, %113
  %128 = phi i32 [ %102, %113 ], [ %102, %99 ], [ %9, %5 ]
  %129 = phi i32 [ %25, %113 ], [ %25, %99 ], [ 0, %5 ]
  %130 = phi %struct.ShipdateRowGlobal* [ %101, %113 ], [ %101, %99 ], [ null, %5 ]
  %131 = phi i64 [ %100, %113 ], [ %100, %99 ], [ 0, %5 ]
  %132 = bitcast %struct.ShipdateRowGlobal* %130 to i8*
  %133 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([36 x i8], [36 x i8]* @str.15, i64 0, i64 0))
  %134 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([19 x i8], [19 x i8]* @.str.11, i64 0, i64 0), i32 noundef %129)
  %135 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([28 x i8], [28 x i8]* @.str.12, i64 0, i64 0), i64 noundef %131)
  %136 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([25 x i8], [25 x i8]* @.str.13, i64 0, i64 0), i64 noundef %131)
  call void @free(i8* noundef %132) #8
  %137 = icmp slt i32 %128, 0
  br i1 %137, label %138, label %140

138:                                              ; preds = %127
  %139 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.14, i64 0, i64 0), i32 noundef %128)
  br label %142

140:                                              ; preds = %127
  %141 = trunc i64 %131 to i32
  br label %142

142:                                              ; preds = %49, %140, %138
  %143 = phi i32 [ %128, %138 ], [ %141, %140 ], [ -1, %49 ]
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %6) #8
  br label %144

144:                                              ; preds = %1, %142
  %145 = phi i32 [ %143, %142 ], [ -1, %1 ]
  ret i32 %145
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare i32 @ndb_arrow_batch_init(%struct.ArrowBatch* noundef) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #3

declare i32 @rt_scan_next(%struct.ScanHandle* noundef, %struct.ArrowBatch* noundef) local_unnamed_addr #2

declare void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef) local_unnamed_addr #2

declare i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef, i32 noundef, %struct.ArrowColumnView* noundef) local_unnamed_addr #2

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn
declare noalias noundef i8* @realloc(i8* nocapture noundef, i64 noundef) local_unnamed_addr #4

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

declare void @pdqsort(i8* noundef, i64 noundef, i64 noundef, i32 (i8*, i8*)* noundef) local_unnamed_addr #2

; Function Attrs: mustprogress nofree norecurse nosync nounwind readonly uwtable willreturn
define internal i32 @compare_shipdate_rows_global(i8* nocapture noundef readonly %0, i8* nocapture noundef readonly %1) #5 {
  %3 = bitcast i8* %0 to i32*
  %4 = load i32, i32* %3, align 4, !tbaa !20
  %5 = bitcast i8* %1 to i32*
  %6 = load i32, i32* %5, align 4, !tbaa !20
  %7 = icmp slt i32 %4, %6
  %8 = icmp sgt i32 %4, %6
  %9 = zext i1 %8 to i32
  %10 = select i1 %7, i32 -1, i32 %9
  ret i32 %10
}

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn
declare void @free(i8* nocapture noundef) local_unnamed_addr #4

; Function Attrs: nofree nounwind
declare noundef i32 @puts(i8* nocapture noundef readonly) local_unnamed_addr #6

; Function Attrs: nofree nounwind
declare noundef i32 @putchar(i32 noundef) local_unnamed_addr #6

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i64 @llvm.umin.i64(i64, i64) #7

attributes #0 = { nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { inaccessiblemem_or_argmemonly mustprogress nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { mustprogress nofree norecurse nosync nounwind readonly uwtable willreturn "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nofree nounwind }
attributes #7 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #8 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
!5 = !{!6, !10, i64 16}
!6 = !{!"ArrowBatch", !7, i64 0, !7, i64 8, !10, i64 16, !11, i64 24, !7, i64 32}
!7 = !{!"any pointer", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = !{!"long", !8, i64 0}
!11 = !{!"int", !8, i64 0}
!12 = distinct !{!12, !13}
!13 = !{!"llvm.loop.mustprogress"}
!14 = !{!15, !7, i64 24}
!15 = !{!"ArrowColumnView", !7, i64 0, !7, i64 8, !7, i64 16, !7, i64 24, !7, i64 32, !7, i64 40, !11, i64 48, !11, i64 52, !10, i64 56, !10, i64 64}
!16 = !{!15, !7, i64 16}
!17 = !{!15, !10, i64 64}
!18 = !{!8, !8, i64 0}
!19 = !{!11, !11, i64 0}
!20 = !{!21, !11, i64 0}
!21 = !{!"", !11, i64 0, !11, i64 4, !11, i64 8}
!22 = !{!21, !11, i64 4}
!23 = !{!21, !11, i64 8}
!24 = distinct !{!24, !13}
!25 = distinct !{!25, !13}
