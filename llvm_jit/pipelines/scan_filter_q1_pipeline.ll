; ModuleID = 'scan_filter_q1_pipeline.c'
source_filename = "scan_filter_q1_pipeline.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.ScanHandle = type opaque
%struct.ArrowBatch = type { %struct.ArrowArray*, %struct.ArrowSchema*, i64, i32, i8* }
%struct.ArrowArray = type { i64, i64, i64, i64, i64, i8**, %struct.ArrowArray**, %struct.ArrowArray*, void (%struct.ArrowArray*)*, i8* }
%struct.ArrowSchema = type { i8*, i8*, i8*, i64, i64, %struct.ArrowSchema**, %struct.ArrowSchema*, void (%struct.ArrowSchema*)*, i8* }
%struct.ArrowColumnView = type { %struct.ArrowArray*, %struct.ArrowSchema*, i8*, i8*, i32*, i8*, i32, i32, i64, i64 }
%struct.SimpleColumnView = type { i32*, i8*, i64, i64, i32 }

@.str.1 = private unnamed_addr constant [43 x i8] c"Failed to get shipdate column in batch %d\0A\00", align 1
@.str.2 = private unnamed_addr constant [45 x i8] c"Batch %d: %lld rows -> %d filtered (%.2f%%)\0A\00", align 1
@.str.4 = private unnamed_addr constant [19 x i8] c"Total batches: %d\0A\00", align 1
@.str.5 = private unnamed_addr constant [26 x i8] c"Total rows scanned: %lld\0A\00", align 1
@.str.6 = private unnamed_addr constant [27 x i8] c"Total rows filtered: %lld\0A\00", align 1
@.str.7 = private unnamed_addr constant [29 x i8] c"Overall selectivity: %.3f%%\0A\00", align 1
@.str.8 = private unnamed_addr constant [23 x i8] c"Error during scan: %d\0A\00", align 1
@str = private unnamed_addr constant [36 x i8] c"=== scan_filter_q1 JIT Pipeline ===\00", align 1
@str.9 = private unnamed_addr constant [32 x i8] c"\0A=== scan_filter_q1 Results ===\00", align 1

; Function Attrs: nounwind uwtable
define dso_local i32 @scan_filter_q1_pipeline_jit(%struct.ScanHandle* noundef %0) local_unnamed_addr #0 {
  %2 = alloca %struct.ArrowBatch, align 8
  %3 = alloca %struct.ArrowColumnView, align 8
  %4 = alloca %struct.SimpleColumnView, align 8
  %5 = icmp eq %struct.ScanHandle* %0, null
  br i1 %5, label %104, label %6

6:                                                ; preds = %1
  %7 = bitcast %struct.ArrowBatch* %2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %7) #7
  %8 = call i32 @ndb_arrow_batch_init(%struct.ArrowBatch* noundef nonnull %2) #7
  %9 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([36 x i8], [36 x i8]* @str, i64 0, i64 0))
  %10 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %11 = icmp sgt i32 %10, 0
  br i1 %11, label %12, label %79

12:                                               ; preds = %6
  %13 = getelementptr inbounds %struct.ArrowBatch, %struct.ArrowBatch* %2, i64 0, i32 2
  %14 = bitcast %struct.ArrowColumnView* %3 to i8*
  %15 = bitcast %struct.SimpleColumnView* %4 to i8*
  %16 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 3
  %17 = bitcast i8** %16 to i32**
  %18 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %4, i64 0, i32 0
  %19 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 2
  %20 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %4, i64 0, i32 1
  %21 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 8
  %22 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %4, i64 0, i32 2
  %23 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 6
  %24 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %4, i64 0, i32 4
  %25 = bitcast i64* %21 to <2 x i64>*
  %26 = bitcast i64* %22 to <2 x i64>*
  br label %27

27:                                               ; preds = %12, %75
  %28 = phi i64 [ 0, %12 ], [ %36, %75 ]
  %29 = phi i64 [ 0, %12 ], [ %76, %75 ]
  %30 = phi i32 [ 0, %12 ], [ %34, %75 ]
  br label %31

31:                                               ; preds = %27, %38
  %32 = phi i64 [ %28, %27 ], [ %36, %38 ]
  %33 = phi i32 [ %30, %27 ], [ %34, %38 ]
  %34 = add nsw i32 %33, 1
  %35 = load i64, i64* %13, align 8, !tbaa !5
  %36 = add nsw i64 %35, %32
  %37 = icmp eq i64 %35, 0
  br i1 %37, label %38, label %41

38:                                               ; preds = %31
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  %39 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %40 = icmp sgt i32 %39, 0
  br i1 %40, label %31, label %79, !llvm.loop !12

41:                                               ; preds = %31
  call void @llvm.lifetime.start.p0i8(i64 72, i8* nonnull %14) #7
  %42 = call i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef nonnull %2, i32 noundef 6, %struct.ArrowColumnView* noundef nonnull %3) #7
  %43 = icmp eq i32 %42, 0
  br i1 %43, label %46, label %44

44:                                               ; preds = %41
  %45 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([43 x i8], [43 x i8]* @.str.1, i64 0, i64 0), i32 noundef %34)
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  br label %75, !llvm.loop !12

46:                                               ; preds = %41
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %15) #7
  %47 = load i32*, i32** %17, align 8, !tbaa !14
  store i32* %47, i32** %18, align 8, !tbaa !16
  %48 = load i8*, i8** %19, align 8, !tbaa !18
  store i8* %48, i8** %20, align 8, !tbaa !19
  %49 = load <2 x i64>, <2 x i64>* %25, align 8, !tbaa !20
  store <2 x i64> %49, <2 x i64>* %26, align 8, !tbaa !20
  %50 = load i32, i32* %23, align 8, !tbaa !21
  store i32 %50, i32* %24, align 8, !tbaa !22
  %51 = load i64, i64* %13, align 8, !tbaa !5
  %52 = shl i64 %51, 2
  %53 = call noalias i8* @malloc(i64 noundef %52) #7
  %54 = icmp eq i8* %53, null
  br i1 %54, label %73, label %55, !llvm.loop !12

55:                                               ; preds = %46
  %56 = bitcast i8* %53 to i32*
  %57 = call i32 @filter_le_date32(%struct.SimpleColumnView* noundef nonnull %4, i32 noundef 10561, i32* noundef nonnull %56) #7
  %58 = icmp sgt i32 %57, -1
  br i1 %58, label %59, label %71

59:                                               ; preds = %55
  %60 = zext i32 %57 to i64
  %61 = add nsw i64 %29, %60
  %62 = srem i32 %34, 100
  %63 = icmp eq i32 %62, 0
  br i1 %63, label %64, label %71

64:                                               ; preds = %59
  %65 = load i64, i64* %13, align 8, !tbaa !5
  %66 = sitofp i32 %57 to double
  %67 = fmul double %66, 1.000000e+02
  %68 = sitofp i64 %65 to double
  %69 = fdiv double %67, %68
  %70 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([45 x i8], [45 x i8]* @.str.2, i64 0, i64 0), i32 noundef %34, i64 noundef %65, i32 noundef %57, double noundef %69)
  br label %71

71:                                               ; preds = %59, %64, %55
  %72 = phi i64 [ %61, %64 ], [ %61, %59 ], [ %29, %55 ]
  call void @free(i8* noundef nonnull %53) #7
  br label %73

73:                                               ; preds = %46, %71
  %74 = phi i64 [ %72, %71 ], [ %29, %46 ]
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %15) #7
  br label %75

75:                                               ; preds = %73, %44
  %76 = phi i64 [ %29, %44 ], [ %74, %73 ]
  call void @llvm.lifetime.end.p0i8(i64 72, i8* nonnull %14) #7
  %77 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %78 = icmp sgt i32 %77, 0
  br i1 %78, label %27, label %79

79:                                               ; preds = %75, %38, %6
  %80 = phi i64 [ 0, %6 ], [ %29, %38 ], [ %76, %75 ]
  %81 = phi i32 [ 0, %6 ], [ %34, %38 ], [ %34, %75 ]
  %82 = phi i64 [ 0, %6 ], [ %36, %38 ], [ %36, %75 ]
  %83 = phi i32 [ %10, %6 ], [ %39, %38 ], [ %77, %75 ]
  %84 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([32 x i8], [32 x i8]* @str.9, i64 0, i64 0))
  %85 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([19 x i8], [19 x i8]* @.str.4, i64 0, i64 0), i32 noundef %81)
  %86 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([26 x i8], [26 x i8]* @.str.5, i64 0, i64 0), i64 noundef %82)
  %87 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([27 x i8], [27 x i8]* @.str.6, i64 0, i64 0), i64 noundef %80)
  %88 = icmp sgt i64 %82, 0
  br i1 %88, label %89, label %94

89:                                               ; preds = %79
  %90 = sitofp i64 %80 to double
  %91 = fmul double %90, 1.000000e+02
  %92 = sitofp i64 %82 to double
  %93 = fdiv double %91, %92
  br label %94

94:                                               ; preds = %79, %89
  %95 = phi double [ %93, %89 ], [ 0.000000e+00, %79 ]
  %96 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([29 x i8], [29 x i8]* @.str.7, i64 0, i64 0), double noundef %95)
  %97 = icmp slt i32 %83, 0
  br i1 %97, label %98, label %100

98:                                               ; preds = %94
  %99 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.8, i64 0, i64 0), i32 noundef %83)
  br label %102

100:                                              ; preds = %94
  %101 = trunc i64 %80 to i32
  br label %102

102:                                              ; preds = %100, %98
  %103 = phi i32 [ %83, %98 ], [ %101, %100 ]
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %7) #7
  br label %104

104:                                              ; preds = %1, %102
  %105 = phi i32 [ %103, %102 ], [ -1, %1 ]
  ret i32 %105
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare i32 @ndb_arrow_batch_init(%struct.ArrowBatch* noundef) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #3

declare i32 @rt_scan_next(%struct.ScanHandle* noundef, %struct.ArrowBatch* noundef) local_unnamed_addr #2

declare void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef) local_unnamed_addr #2

declare i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef, i32 noundef, %struct.ArrowColumnView* noundef) local_unnamed_addr #2

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn
declare noalias noundef i8* @malloc(i64 noundef) local_unnamed_addr #4

declare i32 @filter_le_date32(%struct.SimpleColumnView* noundef, i32 noundef, i32* noundef) local_unnamed_addr #2

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn
declare void @free(i8* nocapture noundef) local_unnamed_addr #5

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

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
