; ModuleID = 'agg_only_q1_pipeline.c'
source_filename = "agg_only_q1_pipeline.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.ScanHandle = type opaque
%struct.ArrowBatch = type { %struct.ArrowArray*, %struct.ArrowSchema*, i64, i32, i8* }
%struct.ArrowArray = type { i64, i64, i64, i64, i64, i8**, %struct.ArrowArray**, %struct.ArrowArray*, void (%struct.ArrowArray*)*, i8* }
%struct.ArrowSchema = type { i8*, i8*, i8*, i64, i64, %struct.ArrowSchema**, %struct.ArrowSchema*, void (%struct.ArrowSchema*)*, i8* }
%struct.Q1AggregationState = type { %struct.Q1HashTable, i8 }
%struct.Q1HashTable = type { [1024 x %struct.Q1HashEntry], i32 }
%struct.Q1HashEntry = type { i8, i8, i64, i64, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, double, double, double, double, double }
%struct.AVX2DoubleSumBuffer = type opaque

@.str.2 = private unnamed_addr constant [51 x i8] c"Batch %d: %lld rows -> %lld aggregated (100.00%%)\0A\00", align 1
@.str.5 = private unnamed_addr constant [19 x i8] c"Total batches: %d\0A\00", align 1
@.str.6 = private unnamed_addr constant [26 x i8] c"Total rows scanned: %lld\0A\00", align 1
@.str.7 = private unnamed_addr constant [29 x i8] c"Total rows aggregated: %lld\0A\00", align 1
@.str.8 = private unnamed_addr constant [24 x i8] c"Aggregation groups: %d\0A\00", align 1
@.str.9 = private unnamed_addr constant [23 x i8] c"Error during scan: %d\0A\00", align 1
@str = private unnamed_addr constant [42 x i8] c"Failed to initialize Q1 aggregation state\00", align 1
@str.10 = private unnamed_addr constant [33 x i8] c"=== agg_only_q1 JIT Pipeline ===\00", align 1
@str.11 = private unnamed_addr constant [42 x i8] c"\0AFinalizing Q1 aggregation and sorting...\00", align 1
@str.12 = private unnamed_addr constant [29 x i8] c"\0A=== agg_only_q1 Results ===\00", align 1

; Function Attrs: nounwind uwtable
define dso_local i32 @agg_only_q1_pipeline_jit(%struct.ScanHandle* noundef %0) local_unnamed_addr #0 {
  %2 = alloca %struct.ArrowBatch, align 8
  %3 = icmp eq %struct.ScanHandle* %0, null
  br i1 %3, label %145, label %4

4:                                                ; preds = %1
  %5 = tail call %struct.Q1AggregationState* @q1_agg_init_optimized() #7
  %6 = icmp eq %struct.Q1AggregationState* %5, null
  br i1 %6, label %7, label %9

7:                                                ; preds = %4
  %8 = tail call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([42 x i8], [42 x i8]* @str, i64 0, i64 0))
  br label %145

9:                                                ; preds = %4
  %10 = bitcast %struct.ArrowBatch* %2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %10) #7
  %11 = call i32 @ndb_arrow_batch_init(%struct.ArrowBatch* noundef nonnull %2) #7
  %12 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([33 x i8], [33 x i8]* @str.10, i64 0, i64 0))
  %13 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %14 = icmp sgt i32 %13, 0
  br i1 %14, label %15, label %125

15:                                               ; preds = %9
  %16 = getelementptr inbounds %struct.ArrowBatch, %struct.ArrowBatch* %2, i64 0, i32 2
  %17 = getelementptr inbounds %struct.ArrowBatch, %struct.ArrowBatch* %2, i64 0, i32 0
  br label %18

18:                                               ; preds = %15, %121
  %19 = phi i32 [ 0, %15 ], [ %25, %121 ]
  %20 = phi i64 [ 0, %15 ], [ %122, %121 ]
  %21 = phi i64 [ 0, %15 ], [ %27, %121 ]
  br label %22

22:                                               ; preds = %18, %29
  %23 = phi i32 [ %19, %18 ], [ %25, %29 ]
  %24 = phi i64 [ %21, %18 ], [ %27, %29 ]
  %25 = add nsw i32 %23, 1
  %26 = load i64, i64* %16, align 8, !tbaa !5
  %27 = add nsw i64 %26, %24
  %28 = icmp eq i64 %26, 0
  br i1 %28, label %29, label %32

29:                                               ; preds = %22
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  %30 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %31 = icmp sgt i32 %30, 0
  br i1 %31, label %22, label %125, !llvm.loop !12

32:                                               ; preds = %22
  %33 = shl i64 %26, 2
  %34 = call noalias i8* @malloc(i64 noundef %33) #7
  %35 = bitcast i8* %34 to i32*
  %36 = icmp eq i8* %34, null
  br i1 %36, label %121, label %37, !llvm.loop !12

37:                                               ; preds = %32
  %38 = icmp sgt i64 %26, 0
  br i1 %38, label %39, label %105

39:                                               ; preds = %37
  %40 = icmp ult i64 %26, 8
  br i1 %40, label %103, label %41

41:                                               ; preds = %39
  %42 = and i64 %26, -8
  %43 = add i64 %42, -8
  %44 = lshr exact i64 %43, 3
  %45 = add nuw nsw i64 %44, 1
  %46 = and i64 %45, 3
  %47 = icmp ult i64 %43, 24
  br i1 %47, label %84, label %48

48:                                               ; preds = %41
  %49 = and i64 %45, 4611686018427387900
  br label %50

50:                                               ; preds = %50, %48
  %51 = phi i64 [ 0, %48 ], [ %80, %50 ]
  %52 = phi <4 x i32> [ <i32 0, i32 1, i32 2, i32 3>, %48 ], [ %81, %50 ]
  %53 = phi i64 [ 0, %48 ], [ %82, %50 ]
  %54 = add <4 x i32> %52, <i32 4, i32 4, i32 4, i32 4>
  %55 = getelementptr inbounds i32, i32* %35, i64 %51
  %56 = bitcast i32* %55 to <4 x i32>*
  store <4 x i32> %52, <4 x i32>* %56, align 4, !tbaa !14
  %57 = getelementptr inbounds i32, i32* %55, i64 4
  %58 = bitcast i32* %57 to <4 x i32>*
  store <4 x i32> %54, <4 x i32>* %58, align 4, !tbaa !14
  %59 = or i64 %51, 8
  %60 = add <4 x i32> %52, <i32 8, i32 8, i32 8, i32 8>
  %61 = add <4 x i32> %52, <i32 12, i32 12, i32 12, i32 12>
  %62 = getelementptr inbounds i32, i32* %35, i64 %59
  %63 = bitcast i32* %62 to <4 x i32>*
  store <4 x i32> %60, <4 x i32>* %63, align 4, !tbaa !14
  %64 = getelementptr inbounds i32, i32* %62, i64 4
  %65 = bitcast i32* %64 to <4 x i32>*
  store <4 x i32> %61, <4 x i32>* %65, align 4, !tbaa !14
  %66 = or i64 %51, 16
  %67 = add <4 x i32> %52, <i32 16, i32 16, i32 16, i32 16>
  %68 = add <4 x i32> %52, <i32 20, i32 20, i32 20, i32 20>
  %69 = getelementptr inbounds i32, i32* %35, i64 %66
  %70 = bitcast i32* %69 to <4 x i32>*
  store <4 x i32> %67, <4 x i32>* %70, align 4, !tbaa !14
  %71 = getelementptr inbounds i32, i32* %69, i64 4
  %72 = bitcast i32* %71 to <4 x i32>*
  store <4 x i32> %68, <4 x i32>* %72, align 4, !tbaa !14
  %73 = or i64 %51, 24
  %74 = add <4 x i32> %52, <i32 24, i32 24, i32 24, i32 24>
  %75 = add <4 x i32> %52, <i32 28, i32 28, i32 28, i32 28>
  %76 = getelementptr inbounds i32, i32* %35, i64 %73
  %77 = bitcast i32* %76 to <4 x i32>*
  store <4 x i32> %74, <4 x i32>* %77, align 4, !tbaa !14
  %78 = getelementptr inbounds i32, i32* %76, i64 4
  %79 = bitcast i32* %78 to <4 x i32>*
  store <4 x i32> %75, <4 x i32>* %79, align 4, !tbaa !14
  %80 = add nuw i64 %51, 32
  %81 = add <4 x i32> %52, <i32 32, i32 32, i32 32, i32 32>
  %82 = add i64 %53, 4
  %83 = icmp eq i64 %82, %49
  br i1 %83, label %84, label %50, !llvm.loop !15

84:                                               ; preds = %50, %41
  %85 = phi i64 [ 0, %41 ], [ %80, %50 ]
  %86 = phi <4 x i32> [ <i32 0, i32 1, i32 2, i32 3>, %41 ], [ %81, %50 ]
  %87 = icmp eq i64 %46, 0
  br i1 %87, label %101, label %88

88:                                               ; preds = %84, %88
  %89 = phi i64 [ %97, %88 ], [ %85, %84 ]
  %90 = phi <4 x i32> [ %98, %88 ], [ %86, %84 ]
  %91 = phi i64 [ %99, %88 ], [ 0, %84 ]
  %92 = add <4 x i32> %90, <i32 4, i32 4, i32 4, i32 4>
  %93 = getelementptr inbounds i32, i32* %35, i64 %89
  %94 = bitcast i32* %93 to <4 x i32>*
  store <4 x i32> %90, <4 x i32>* %94, align 4, !tbaa !14
  %95 = getelementptr inbounds i32, i32* %93, i64 4
  %96 = bitcast i32* %95 to <4 x i32>*
  store <4 x i32> %92, <4 x i32>* %96, align 4, !tbaa !14
  %97 = add nuw i64 %89, 8
  %98 = add <4 x i32> %90, <i32 8, i32 8, i32 8, i32 8>
  %99 = add i64 %91, 1
  %100 = icmp eq i64 %99, %46
  br i1 %100, label %101, label %88, !llvm.loop !17

101:                                              ; preds = %88, %84
  %102 = icmp eq i64 %26, %42
  br i1 %102, label %105, label %103

103:                                              ; preds = %39, %101
  %104 = phi i64 [ 0, %39 ], [ %42, %101 ]
  br label %112

105:                                              ; preds = %112, %101, %37
  %106 = load %struct.ArrowArray*, %struct.ArrowArray** %17, align 8, !tbaa !19
  %107 = trunc i64 %26 to i32
  call void @q1_agg_process_batch_optimized(%struct.Q1AggregationState* noundef nonnull %5, %struct.ArrowArray* noundef %106, i32* noundef nonnull %35, i32 noundef %107) #7
  %108 = load i64, i64* %16, align 8, !tbaa !5
  %109 = add nsw i64 %108, %20
  %110 = srem i32 %25, 100
  %111 = icmp eq i32 %110, 0
  br i1 %111, label %118, label %120

112:                                              ; preds = %103, %112
  %113 = phi i64 [ %116, %112 ], [ %104, %103 ]
  %114 = trunc i64 %113 to i32
  %115 = getelementptr inbounds i32, i32* %35, i64 %113
  store i32 %114, i32* %115, align 4, !tbaa !14
  %116 = add nuw nsw i64 %113, 1
  %117 = icmp eq i64 %116, %26
  br i1 %117, label %105, label %112, !llvm.loop !20

118:                                              ; preds = %105
  %119 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([51 x i8], [51 x i8]* @.str.2, i64 0, i64 0), i32 noundef %25, i64 noundef %108, i64 noundef %108)
  br label %120

120:                                              ; preds = %118, %105
  call void @free(i8* noundef nonnull %34) #7
  br label %121

121:                                              ; preds = %32, %120
  %122 = phi i64 [ %109, %120 ], [ %20, %32 ]
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  %123 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %124 = icmp sgt i32 %123, 0
  br i1 %124, label %18, label %125

125:                                              ; preds = %121, %29, %9
  %126 = phi i64 [ 0, %9 ], [ %20, %29 ], [ %122, %121 ]
  %127 = phi i64 [ 0, %9 ], [ %27, %29 ], [ %27, %121 ]
  %128 = phi i32 [ 0, %9 ], [ %25, %29 ], [ %25, %121 ]
  %129 = phi i32 [ %13, %9 ], [ %30, %29 ], [ %123, %121 ]
  %130 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([42 x i8], [42 x i8]* @str.11, i64 0, i64 0))
  call void @q1_agg_finalize_optimized(%struct.Q1AggregationState* noundef nonnull %5) #7
  %131 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([29 x i8], [29 x i8]* @str.12, i64 0, i64 0))
  %132 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([19 x i8], [19 x i8]* @.str.5, i64 0, i64 0), i32 noundef %128)
  %133 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([26 x i8], [26 x i8]* @.str.6, i64 0, i64 0), i64 noundef %127)
  %134 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([29 x i8], [29 x i8]* @.str.7, i64 0, i64 0), i64 noundef %126)
  %135 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %5, i64 0, i32 0, i32 1
  %136 = load i32, i32* %135, align 8, !tbaa !22
  %137 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([24 x i8], [24 x i8]* @.str.8, i64 0, i64 0), i32 noundef %136)
  call void @q1_agg_destroy_optimized(%struct.Q1AggregationState* noundef nonnull %5) #7
  %138 = icmp slt i32 %129, 0
  br i1 %138, label %139, label %141

139:                                              ; preds = %125
  %140 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.9, i64 0, i64 0), i32 noundef %129)
  br label %143

141:                                              ; preds = %125
  %142 = trunc i64 %126 to i32
  br label %143

143:                                              ; preds = %141, %139
  %144 = phi i32 [ %129, %139 ], [ %142, %141 ]
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %10) #7
  br label %145

145:                                              ; preds = %7, %143, %1
  %146 = phi i32 [ -1, %1 ], [ %144, %143 ], [ -1, %7 ]
  ret i32 %146
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare %struct.Q1AggregationState* @q1_agg_init_optimized() local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #3

declare i32 @ndb_arrow_batch_init(%struct.ArrowBatch* noundef) local_unnamed_addr #2

declare i32 @rt_scan_next(%struct.ScanHandle* noundef, %struct.ArrowBatch* noundef) local_unnamed_addr #2

declare void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef) local_unnamed_addr #2

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn
declare noalias noundef i8* @malloc(i64 noundef) local_unnamed_addr #4

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

declare void @q1_agg_process_batch_optimized(%struct.Q1AggregationState* noundef, %struct.ArrowArray* noundef, i32* noundef, i32 noundef) local_unnamed_addr #2

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn
declare void @free(i8* nocapture noundef) local_unnamed_addr #5

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
!14 = !{!11, !11, i64 0}
!15 = distinct !{!15, !13, !16}
!16 = !{!"llvm.loop.isvectorized", i32 1}
!17 = distinct !{!17, !18}
!18 = !{!"llvm.loop.unroll.disable"}
!19 = !{!6, !7, i64 0}
!20 = distinct !{!20, !13, !21, !16}
!21 = !{!"llvm.loop.unroll.runtime.disable"}
!22 = !{!23, !11, i64 106496}
!23 = !{!"", !24, i64 0, !25, i64 106504}
!24 = !{!"", !8, i64 0, !11, i64 106496}
!25 = !{!"_Bool", !8, i64 0}
