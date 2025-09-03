; ModuleID = 'q1_full_pipeline.c'
source_filename = "q1_full_pipeline.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.ScanHandle = type opaque
%struct.ArrowBatch = type { %struct.ArrowArray*, %struct.ArrowSchema*, i64, i32, i8* }
%struct.ArrowArray = type { i64, i64, i64, i64, i64, i8**, %struct.ArrowArray**, %struct.ArrowArray*, void (%struct.ArrowArray*)*, i8* }
%struct.ArrowSchema = type { i8*, i8*, i8*, i64, i64, %struct.ArrowSchema**, %struct.ArrowSchema*, void (%struct.ArrowSchema*)*, i8* }
%struct.ArrowColumnView = type { %struct.ArrowArray*, %struct.ArrowSchema*, i8*, i8*, i32*, i8*, i32, i32, i64, i64 }
%struct.SimpleColumnView = type { i32*, i8*, i64, i64, i32 }
%struct.Q1AggregationState = type { %struct.Q1HashTable, i8 }
%struct.Q1HashTable = type { [1024 x %struct.Q1HashEntry], i32 }
%struct.Q1HashEntry = type { i8, i8, i64, i64, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, double, double, double, double, double }
%struct.AVX2DoubleSumBuffer = type opaque

@.str.2 = private unnamed_addr constant [43 x i8] c"Failed to get shipdate column in batch %d\0A\00", align 1
@.str.3 = private unnamed_addr constant [62 x i8] c"Batch %d: %lld rows -> %d filtered -> %d aggregated (%.2f%%)\0A\00", align 1
@.str.6 = private unnamed_addr constant [19 x i8] c"Total batches: %d\0A\00", align 1
@.str.7 = private unnamed_addr constant [26 x i8] c"Total rows scanned: %lld\0A\00", align 1
@.str.8 = private unnamed_addr constant [27 x i8] c"Total rows filtered: %lld\0A\00", align 1
@.str.9 = private unnamed_addr constant [29 x i8] c"Total rows aggregated: %lld\0A\00", align 1
@.str.10 = private unnamed_addr constant [24 x i8] c"Aggregation groups: %d\0A\00", align 1
@.str.11 = private unnamed_addr constant [29 x i8] c"Overall selectivity: %.3f%%\0A\00", align 1
@.str.12 = private unnamed_addr constant [23 x i8] c"Error during scan: %d\0A\00", align 1
@str = private unnamed_addr constant [42 x i8] c"Failed to initialize Q1 aggregation state\00", align 1
@str.13 = private unnamed_addr constant [29 x i8] c"=== q1_full JIT Pipeline ===\00", align 1
@str.14 = private unnamed_addr constant [42 x i8] c"\0AFinalizing Q1 aggregation and sorting...\00", align 1
@str.15 = private unnamed_addr constant [25 x i8] c"\0A=== q1_full Results ===\00", align 1

; Function Attrs: nounwind uwtable
define dso_local i32 @q1_full_pipeline_jit(%struct.ScanHandle* noundef %0) local_unnamed_addr #0 {
  %2 = alloca %struct.ArrowBatch, align 8
  %3 = alloca %struct.ArrowColumnView, align 8
  %4 = alloca %struct.SimpleColumnView, align 8
  %5 = icmp eq %struct.ScanHandle* %0, null
  br i1 %5, label %122, label %6

6:                                                ; preds = %1
  %7 = tail call %struct.Q1AggregationState* @q1_agg_init_optimized() #7
  %8 = icmp eq %struct.Q1AggregationState* %7, null
  br i1 %8, label %9, label %11

9:                                                ; preds = %6
  %10 = tail call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([42 x i8], [42 x i8]* @str, i64 0, i64 0))
  br label %122

11:                                               ; preds = %6
  %12 = bitcast %struct.ArrowBatch* %2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %12) #7
  %13 = call i32 @ndb_arrow_batch_init(%struct.ArrowBatch* noundef nonnull %2) #7
  %14 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([29 x i8], [29 x i8]* @str.13, i64 0, i64 0))
  %15 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %16 = icmp sgt i32 %15, 0
  br i1 %16, label %17, label %91

17:                                               ; preds = %11
  %18 = getelementptr inbounds %struct.ArrowBatch, %struct.ArrowBatch* %2, i64 0, i32 2
  %19 = bitcast %struct.ArrowColumnView* %3 to i8*
  %20 = bitcast %struct.SimpleColumnView* %4 to i8*
  %21 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 3
  %22 = bitcast i8** %21 to i32**
  %23 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %4, i64 0, i32 0
  %24 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 2
  %25 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %4, i64 0, i32 1
  %26 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 8
  %27 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %4, i64 0, i32 2
  %28 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 6
  %29 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %4, i64 0, i32 4
  %30 = getelementptr inbounds %struct.ArrowBatch, %struct.ArrowBatch* %2, i64 0, i32 0
  %31 = bitcast i64* %26 to <2 x i64>*
  %32 = bitcast i64* %27 to <2 x i64>*
  br label %33

33:                                               ; preds = %17, %86
  %34 = phi i64 [ 0, %17 ], [ %43, %86 ]
  %35 = phi i32 [ 0, %17 ], [ %41, %86 ]
  %36 = phi i64 [ 0, %17 ], [ %88, %86 ]
  %37 = phi i64 [ 0, %17 ], [ %87, %86 ]
  br label %38

38:                                               ; preds = %33, %45
  %39 = phi i64 [ %34, %33 ], [ %43, %45 ]
  %40 = phi i32 [ %35, %33 ], [ %41, %45 ]
  %41 = add nsw i32 %40, 1
  %42 = load i64, i64* %18, align 8, !tbaa !5
  %43 = add nsw i64 %42, %39
  %44 = icmp eq i64 %42, 0
  br i1 %44, label %45, label %48

45:                                               ; preds = %38
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  %46 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %47 = icmp sgt i32 %46, 0
  br i1 %47, label %38, label %91, !llvm.loop !12

48:                                               ; preds = %38
  call void @llvm.lifetime.start.p0i8(i64 72, i8* nonnull %19) #7
  %49 = call i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef nonnull %2, i32 noundef 6, %struct.ArrowColumnView* noundef nonnull %3) #7
  %50 = icmp eq i32 %49, 0
  br i1 %50, label %53, label %51

51:                                               ; preds = %48
  %52 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([43 x i8], [43 x i8]* @.str.2, i64 0, i64 0), i32 noundef %41)
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  br label %86, !llvm.loop !12

53:                                               ; preds = %48
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %20) #7
  %54 = load i32*, i32** %22, align 8, !tbaa !14
  store i32* %54, i32** %23, align 8, !tbaa !16
  %55 = load i8*, i8** %24, align 8, !tbaa !18
  store i8* %55, i8** %25, align 8, !tbaa !19
  %56 = load <2 x i64>, <2 x i64>* %31, align 8, !tbaa !20
  store <2 x i64> %56, <2 x i64>* %32, align 8, !tbaa !20
  %57 = load i32, i32* %28, align 8, !tbaa !21
  store i32 %57, i32* %29, align 8, !tbaa !22
  %58 = load i64, i64* %18, align 8, !tbaa !5
  %59 = shl i64 %58, 2
  %60 = call noalias i8* @malloc(i64 noundef %59) #7
  %61 = bitcast i8* %60 to i32*
  %62 = icmp eq i8* %60, null
  br i1 %62, label %83, label %63, !llvm.loop !12

63:                                               ; preds = %53
  %64 = call i32 @filter_le_date32(%struct.SimpleColumnView* noundef nonnull %4, i32 noundef 10561, i32* noundef nonnull %61) #7
  %65 = icmp sgt i32 %64, 0
  br i1 %65, label %66, label %80

66:                                               ; preds = %63
  %67 = zext i32 %64 to i64
  %68 = add nsw i64 %37, %67
  %69 = load %struct.ArrowArray*, %struct.ArrowArray** %30, align 8, !tbaa !23
  call void @q1_agg_process_batch_optimized(%struct.Q1AggregationState* noundef nonnull %7, %struct.ArrowArray* noundef %69, i32* noundef nonnull %61, i32 noundef %64) #7
  %70 = add nsw i64 %36, %67
  %71 = srem i32 %41, 100
  %72 = icmp eq i32 %71, 0
  br i1 %72, label %73, label %80

73:                                               ; preds = %66
  %74 = load i64, i64* %18, align 8, !tbaa !5
  %75 = sitofp i32 %64 to double
  %76 = fmul double %75, 1.000000e+02
  %77 = sitofp i64 %74 to double
  %78 = fdiv double %76, %77
  %79 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([62 x i8], [62 x i8]* @.str.3, i64 0, i64 0), i32 noundef %41, i64 noundef %74, i32 noundef %64, i32 noundef %64, double noundef %78)
  br label %80

80:                                               ; preds = %66, %73, %63
  %81 = phi i64 [ %68, %73 ], [ %68, %66 ], [ %37, %63 ]
  %82 = phi i64 [ %70, %73 ], [ %70, %66 ], [ %36, %63 ]
  call void @free(i8* noundef nonnull %60) #7
  br label %83

83:                                               ; preds = %53, %80
  %84 = phi i64 [ %81, %80 ], [ %37, %53 ]
  %85 = phi i64 [ %82, %80 ], [ %36, %53 ]
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %20) #7
  br label %86

86:                                               ; preds = %83, %51
  %87 = phi i64 [ %37, %51 ], [ %84, %83 ]
  %88 = phi i64 [ %36, %51 ], [ %85, %83 ]
  call void @llvm.lifetime.end.p0i8(i64 72, i8* nonnull %19) #7
  %89 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %90 = icmp sgt i32 %89, 0
  br i1 %90, label %33, label %91

91:                                               ; preds = %86, %45, %11
  %92 = phi i64 [ 0, %11 ], [ %37, %45 ], [ %87, %86 ]
  %93 = phi i64 [ 0, %11 ], [ %36, %45 ], [ %88, %86 ]
  %94 = phi i32 [ 0, %11 ], [ %41, %45 ], [ %41, %86 ]
  %95 = phi i64 [ 0, %11 ], [ %43, %45 ], [ %43, %86 ]
  %96 = phi i32 [ %15, %11 ], [ %46, %45 ], [ %89, %86 ]
  %97 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([42 x i8], [42 x i8]* @str.14, i64 0, i64 0))
  call void @q1_agg_finalize_optimized(%struct.Q1AggregationState* noundef nonnull %7) #7
  %98 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([25 x i8], [25 x i8]* @str.15, i64 0, i64 0))
  %99 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([19 x i8], [19 x i8]* @.str.6, i64 0, i64 0), i32 noundef %94)
  %100 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([26 x i8], [26 x i8]* @.str.7, i64 0, i64 0), i64 noundef %95)
  %101 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([27 x i8], [27 x i8]* @.str.8, i64 0, i64 0), i64 noundef %92)
  %102 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([29 x i8], [29 x i8]* @.str.9, i64 0, i64 0), i64 noundef %93)
  %103 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %7, i64 0, i32 0, i32 1
  %104 = load i32, i32* %103, align 8, !tbaa !24
  %105 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([24 x i8], [24 x i8]* @.str.10, i64 0, i64 0), i32 noundef %104)
  %106 = icmp sgt i64 %95, 0
  br i1 %106, label %107, label %112

107:                                              ; preds = %91
  %108 = sitofp i64 %92 to double
  %109 = fmul double %108, 1.000000e+02
  %110 = sitofp i64 %95 to double
  %111 = fdiv double %109, %110
  br label %112

112:                                              ; preds = %91, %107
  %113 = phi double [ %111, %107 ], [ 0.000000e+00, %91 ]
  %114 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([29 x i8], [29 x i8]* @.str.11, i64 0, i64 0), double noundef %113)
  call void @q1_agg_destroy_optimized(%struct.Q1AggregationState* noundef nonnull %7) #7
  %115 = icmp slt i32 %96, 0
  br i1 %115, label %116, label %118

116:                                              ; preds = %112
  %117 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.12, i64 0, i64 0), i32 noundef %96)
  br label %120

118:                                              ; preds = %112
  %119 = trunc i64 %93 to i32
  br label %120

120:                                              ; preds = %118, %116
  %121 = phi i32 [ %96, %116 ], [ %119, %118 ]
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %12) #7
  br label %122

122:                                              ; preds = %9, %120, %1
  %123 = phi i32 [ -1, %1 ], [ %121, %120 ], [ -1, %9 ]
  ret i32 %123
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare %struct.Q1AggregationState* @q1_agg_init_optimized() local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #3

declare i32 @ndb_arrow_batch_init(%struct.ArrowBatch* noundef) local_unnamed_addr #2

declare i32 @rt_scan_next(%struct.ScanHandle* noundef, %struct.ArrowBatch* noundef) local_unnamed_addr #2

declare void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef) local_unnamed_addr #2

declare i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef, i32 noundef, %struct.ArrowColumnView* noundef) local_unnamed_addr #2

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn
declare noalias noundef i8* @malloc(i64 noundef) local_unnamed_addr #4

declare i32 @filter_le_date32(%struct.SimpleColumnView* noundef, i32 noundef, i32* noundef) local_unnamed_addr #2

declare void @q1_agg_process_batch_optimized(%struct.Q1AggregationState* noundef, %struct.ArrowArray* noundef, i32* noundef, i32 noundef) local_unnamed_addr #2

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn
declare void @free(i8* nocapture noundef) local_unnamed_addr #5

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

declare void @q1_agg_finalize_optimized(%struct.Q1AggregationState* noundef) local_unnamed_addr #2

declare void @q1_agg_destroy_optimized(%struct.Q1AggregationState* noundef) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare noundef i32 @puts(i8* nocapture noundef readonly) local_unnamed_addr #6

attributes #0 = { nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { inaccessiblememonly mustprogress nofree nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { inaccessiblemem_or_argmemonly mustprogress nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nofree nounwind }
attributes #7 = { nounwind }

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
!16 = !{!17, !7, i64 0}
!17 = !{!"", !7, i64 0, !7, i64 8, !10, i64 16, !10, i64 24, !11, i64 32}
!18 = !{!15, !7, i64 16}
!19 = !{!17, !7, i64 8}
!20 = !{!10, !10, i64 0}
!21 = !{!15, !11, i64 48}
!22 = !{!17, !11, i64 32}
!23 = !{!6, !7, i64 0}
!24 = !{!25, !11, i64 106496}
!25 = !{!"", !26, i64 0, !27, i64 106504}
!26 = !{!"", !8, i64 0, !11, i64 106496}
!27 = !{!"_Bool", !8, i64 0}
