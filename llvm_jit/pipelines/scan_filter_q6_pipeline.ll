; ModuleID = 'scan_filter_q6_pipeline.c'
source_filename = "scan_filter_q6_pipeline.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.ScanHandle = type opaque
%struct.ArrowBatch = type { %struct.ArrowArray*, %struct.ArrowSchema*, i64, i32, i8* }
%struct.ArrowArray = type { i64, i64, i64, i64, i64, i8**, %struct.ArrowArray**, %struct.ArrowArray*, void (%struct.ArrowArray*)*, i8* }
%struct.ArrowSchema = type { i8*, i8*, i8*, i64, i64, %struct.ArrowSchema**, %struct.ArrowSchema*, void (%struct.ArrowSchema*)*, i8* }
%struct.ArrowColumnView = type { %struct.ArrowArray*, %struct.ArrowSchema*, i8*, i8*, i32*, i8*, i32, i32, i64, i64 }
%struct.SimpleColumnView = type { i32*, i8*, i64, i64, i32 }

@.str.1 = private unnamed_addr constant [44 x i8] c"Failed to get required columns in batch %d\0A\00", align 1
@.str.2 = private unnamed_addr constant [45 x i8] c"Batch %d: %lld rows -> %d filtered (%.4f%%)\0A\00", align 1
@.str.4 = private unnamed_addr constant [19 x i8] c"Total batches: %d\0A\00", align 1
@.str.5 = private unnamed_addr constant [26 x i8] c"Total rows scanned: %lld\0A\00", align 1
@.str.6 = private unnamed_addr constant [27 x i8] c"Total rows filtered: %lld\0A\00", align 1
@.str.7 = private unnamed_addr constant [29 x i8] c"Overall selectivity: %.4f%%\0A\00", align 1
@.str.8 = private unnamed_addr constant [23 x i8] c"Error during scan: %d\0A\00", align 1
@str = private unnamed_addr constant [36 x i8] c"=== scan_filter_q6 JIT Pipeline ===\00", align 1
@str.9 = private unnamed_addr constant [32 x i8] c"\0A=== scan_filter_q6 Results ===\00", align 1

; Function Attrs: nounwind uwtable
define dso_local i32 @scan_filter_q6_pipeline_jit(%struct.ScanHandle* noundef %0) local_unnamed_addr #0 {
  %2 = alloca %struct.ArrowBatch, align 8
  %3 = alloca %struct.ArrowColumnView, align 8
  %4 = alloca %struct.ArrowColumnView, align 8
  %5 = alloca %struct.ArrowColumnView, align 8
  %6 = alloca %struct.SimpleColumnView, align 8
  %7 = alloca %struct.SimpleColumnView, align 8
  %8 = alloca %struct.SimpleColumnView, align 8
  %9 = icmp eq %struct.ScanHandle* %0, null
  br i1 %9, label %171, label %10

10:                                               ; preds = %1
  %11 = bitcast %struct.ArrowBatch* %2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %11) #7
  %12 = call i32 @ndb_arrow_batch_init(%struct.ArrowBatch* noundef nonnull %2) #7
  %13 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([36 x i8], [36 x i8]* @str, i64 0, i64 0))
  %14 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %15 = icmp sgt i32 %14, 0
  br i1 %15, label %16, label %146

16:                                               ; preds = %10
  %17 = getelementptr inbounds %struct.ArrowBatch, %struct.ArrowBatch* %2, i64 0, i32 2
  %18 = bitcast %struct.ArrowColumnView* %3 to i8*
  %19 = bitcast %struct.ArrowColumnView* %4 to i8*
  %20 = bitcast %struct.ArrowColumnView* %5 to i8*
  %21 = bitcast %struct.SimpleColumnView* %6 to i8*
  %22 = bitcast %struct.SimpleColumnView* %7 to i8*
  %23 = bitcast %struct.SimpleColumnView* %8 to i8*
  %24 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 3
  %25 = bitcast i8** %24 to i32**
  %26 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %6, i64 0, i32 0
  %27 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 2
  %28 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %6, i64 0, i32 1
  %29 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 8
  %30 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %6, i64 0, i32 2
  %31 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 6
  %32 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %6, i64 0, i32 4
  %33 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %4, i64 0, i32 3
  %34 = bitcast i8** %33 to i32**
  %35 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %7, i64 0, i32 0
  %36 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %4, i64 0, i32 2
  %37 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %7, i64 0, i32 1
  %38 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %4, i64 0, i32 8
  %39 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %7, i64 0, i32 2
  %40 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %4, i64 0, i32 6
  %41 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %7, i64 0, i32 4
  %42 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %5, i64 0, i32 3
  %43 = bitcast i8** %42 to i32**
  %44 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %8, i64 0, i32 0
  %45 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %5, i64 0, i32 2
  %46 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %8, i64 0, i32 1
  %47 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %5, i64 0, i32 8
  %48 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %8, i64 0, i32 2
  %49 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %5, i64 0, i32 6
  %50 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %8, i64 0, i32 4
  %51 = bitcast i64* %29 to <2 x i64>*
  %52 = bitcast i64* %30 to <2 x i64>*
  %53 = bitcast i64* %38 to <2 x i64>*
  %54 = bitcast i64* %39 to <2 x i64>*
  %55 = bitcast i64* %47 to <2 x i64>*
  %56 = bitcast i64* %48 to <2 x i64>*
  br label %57

57:                                               ; preds = %16, %142
  %58 = phi i64 [ 0, %16 ], [ %66, %142 ]
  %59 = phi i64 [ 0, %16 ], [ %143, %142 ]
  %60 = phi i32 [ 0, %16 ], [ %64, %142 ]
  br label %61

61:                                               ; preds = %57, %68
  %62 = phi i64 [ %58, %57 ], [ %66, %68 ]
  %63 = phi i32 [ %60, %57 ], [ %64, %68 ]
  %64 = add nsw i32 %63, 1
  %65 = load i64, i64* %17, align 8, !tbaa !5
  %66 = add nsw i64 %65, %62
  %67 = icmp eq i64 %65, 0
  br i1 %67, label %68, label %71

68:                                               ; preds = %61
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  %69 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %70 = icmp sgt i32 %69, 0
  br i1 %70, label %61, label %146, !llvm.loop !12

71:                                               ; preds = %61
  call void @llvm.lifetime.start.p0i8(i64 72, i8* nonnull %18) #7
  call void @llvm.lifetime.start.p0i8(i64 72, i8* nonnull %19) #7
  call void @llvm.lifetime.start.p0i8(i64 72, i8* nonnull %20) #7
  %72 = call i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef nonnull %2, i32 noundef 3, %struct.ArrowColumnView* noundef nonnull %3) #7
  %73 = icmp eq i32 %72, 0
  br i1 %73, label %74, label %80

74:                                               ; preds = %71
  %75 = call i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef nonnull %2, i32 noundef 2, %struct.ArrowColumnView* noundef nonnull %4) #7
  %76 = icmp eq i32 %75, 0
  br i1 %76, label %77, label %80

77:                                               ; preds = %74
  %78 = call i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef nonnull %2, i32 noundef 0, %struct.ArrowColumnView* noundef nonnull %5) #7
  %79 = icmp eq i32 %78, 0
  br i1 %79, label %82, label %80

80:                                               ; preds = %77, %74, %71
  %81 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([44 x i8], [44 x i8]* @.str.1, i64 0, i64 0), i32 noundef %64)
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  br label %142, !llvm.loop !12

82:                                               ; preds = %77
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %21) #7
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %22) #7
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %23) #7
  %83 = load i32*, i32** %25, align 8, !tbaa !14
  store i32* %83, i32** %26, align 8, !tbaa !16
  %84 = load i8*, i8** %27, align 8, !tbaa !18
  store i8* %84, i8** %28, align 8, !tbaa !19
  %85 = load <2 x i64>, <2 x i64>* %51, align 8, !tbaa !20
  store <2 x i64> %85, <2 x i64>* %52, align 8, !tbaa !20
  %86 = load i32, i32* %31, align 8, !tbaa !21
  store i32 %86, i32* %32, align 8, !tbaa !22
  %87 = load i32*, i32** %34, align 8, !tbaa !14
  store i32* %87, i32** %35, align 8, !tbaa !16
  %88 = load i8*, i8** %36, align 8, !tbaa !18
  store i8* %88, i8** %37, align 8, !tbaa !19
  %89 = load <2 x i64>, <2 x i64>* %53, align 8, !tbaa !20
  store <2 x i64> %89, <2 x i64>* %54, align 8, !tbaa !20
  %90 = load i32, i32* %40, align 8, !tbaa !21
  store i32 %90, i32* %41, align 8, !tbaa !22
  %91 = load i32*, i32** %43, align 8, !tbaa !14
  store i32* %91, i32** %44, align 8, !tbaa !16
  %92 = load i8*, i8** %45, align 8, !tbaa !18
  store i8* %92, i8** %46, align 8, !tbaa !19
  %93 = load <2 x i64>, <2 x i64>* %55, align 8, !tbaa !20
  store <2 x i64> %93, <2 x i64>* %56, align 8, !tbaa !20
  %94 = load i32, i32* %49, align 8, !tbaa !21
  store i32 %94, i32* %50, align 8, !tbaa !22
  %95 = load i64, i64* %17, align 8, !tbaa !5
  %96 = shl i64 %95, 2
  %97 = call noalias i8* @malloc(i64 noundef %96) #7
  %98 = bitcast i8* %97 to i32*
  %99 = call noalias i8* @malloc(i64 noundef %96) #7
  %100 = bitcast i8* %99 to i32*
  %101 = call noalias i8* @malloc(i64 noundef %96) #7
  %102 = bitcast i8* %101 to i32*
  %103 = call noalias i8* @malloc(i64 noundef %96) #7
  %104 = bitcast i8* %103 to i32*
  %105 = icmp ne i8* %97, null
  %106 = icmp ne i8* %99, null
  %107 = and i1 %105, %106
  %108 = icmp ne i8* %101, null
  %109 = and i1 %107, %108
  %110 = icmp ne i8* %103, null
  %111 = and i1 %109, %110
  br i1 %111, label %113, label %112

112:                                              ; preds = %82
  call void @free(i8* noundef %97) #7
  call void @free(i8* noundef %99) #7
  call void @free(i8* noundef %101) #7
  call void @free(i8* noundef %103) #7
  br label %140, !llvm.loop !12

113:                                              ; preds = %82
  %114 = call i32 @filter_ge_date32(%struct.SimpleColumnView* noundef nonnull %6, i32 noundef 8766, i32* noundef nonnull %100) #7
  %115 = icmp sgt i32 %114, 0
  br i1 %115, label %116, label %125

116:                                              ; preds = %113
  %117 = call i32 @filter_lt_date32_on_sel(i32* noundef nonnull %100, i32 noundef %114, %struct.SimpleColumnView* noundef nonnull %6, i32 noundef 9131, i32* noundef nonnull %102) #7
  %118 = icmp sgt i32 %117, 0
  br i1 %118, label %119, label %125

119:                                              ; preds = %116
  %120 = call i32 @filter_between_i64_on_sel(i32* noundef nonnull %102, i32 noundef %117, %struct.SimpleColumnView* noundef nonnull %7, i64 noundef 5, i64 noundef 7, i32* noundef nonnull %104) #7
  %121 = icmp sgt i32 %120, 0
  br i1 %121, label %122, label %125

122:                                              ; preds = %119
  %123 = call i32 @filter_lt_i64_on_sel(i32* noundef nonnull %104, i32 noundef %120, %struct.SimpleColumnView* noundef nonnull %8, i64 noundef 2400, i32* noundef nonnull %98) #7
  %124 = icmp sgt i32 %123, -1
  br i1 %124, label %125, label %138

125:                                              ; preds = %119, %116, %113, %122
  %126 = phi i32 [ %123, %122 ], [ 0, %113 ], [ 0, %116 ], [ 0, %119 ]
  %127 = zext i32 %126 to i64
  %128 = add nsw i64 %59, %127
  %129 = srem i32 %64, 100
  %130 = icmp eq i32 %129, 0
  br i1 %130, label %131, label %138

131:                                              ; preds = %125
  %132 = load i64, i64* %17, align 8, !tbaa !5
  %133 = sitofp i32 %126 to double
  %134 = fmul double %133, 1.000000e+02
  %135 = sitofp i64 %132 to double
  %136 = fdiv double %134, %135
  %137 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([45 x i8], [45 x i8]* @.str.2, i64 0, i64 0), i32 noundef %64, i64 noundef %132, i32 noundef %126, double noundef %136)
  br label %138

138:                                              ; preds = %125, %131, %122
  %139 = phi i64 [ %128, %131 ], [ %128, %125 ], [ %59, %122 ]
  call void @free(i8* noundef nonnull %97) #7
  call void @free(i8* noundef nonnull %99) #7
  call void @free(i8* noundef nonnull %101) #7
  call void @free(i8* noundef nonnull %103) #7
  br label %140

140:                                              ; preds = %138, %112
  %141 = phi i64 [ %139, %138 ], [ %59, %112 ]
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %23) #7
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %22) #7
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %21) #7
  br label %142

142:                                              ; preds = %140, %80
  %143 = phi i64 [ %59, %80 ], [ %141, %140 ]
  call void @llvm.lifetime.end.p0i8(i64 72, i8* nonnull %20) #7
  call void @llvm.lifetime.end.p0i8(i64 72, i8* nonnull %19) #7
  call void @llvm.lifetime.end.p0i8(i64 72, i8* nonnull %18) #7
  %144 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %145 = icmp sgt i32 %144, 0
  br i1 %145, label %57, label %146

146:                                              ; preds = %142, %68, %10
  %147 = phi i64 [ 0, %10 ], [ %59, %68 ], [ %143, %142 ]
  %148 = phi i32 [ 0, %10 ], [ %64, %68 ], [ %64, %142 ]
  %149 = phi i64 [ 0, %10 ], [ %66, %68 ], [ %66, %142 ]
  %150 = phi i32 [ %14, %10 ], [ %69, %68 ], [ %144, %142 ]
  %151 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([32 x i8], [32 x i8]* @str.9, i64 0, i64 0))
  %152 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([19 x i8], [19 x i8]* @.str.4, i64 0, i64 0), i32 noundef %148)
  %153 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([26 x i8], [26 x i8]* @.str.5, i64 0, i64 0), i64 noundef %149)
  %154 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([27 x i8], [27 x i8]* @.str.6, i64 0, i64 0), i64 noundef %147)
  %155 = icmp sgt i64 %149, 0
  br i1 %155, label %156, label %161

156:                                              ; preds = %146
  %157 = sitofp i64 %147 to double
  %158 = fmul double %157, 1.000000e+02
  %159 = sitofp i64 %149 to double
  %160 = fdiv double %158, %159
  br label %161

161:                                              ; preds = %146, %156
  %162 = phi double [ %160, %156 ], [ 0.000000e+00, %146 ]
  %163 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([29 x i8], [29 x i8]* @.str.7, i64 0, i64 0), double noundef %162)
  %164 = icmp slt i32 %150, 0
  br i1 %164, label %165, label %167

165:                                              ; preds = %161
  %166 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.8, i64 0, i64 0), i32 noundef %150)
  br label %169

167:                                              ; preds = %161
  %168 = trunc i64 %147 to i32
  br label %169

169:                                              ; preds = %167, %165
  %170 = phi i32 [ %150, %165 ], [ %168, %167 ]
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %11) #7
  br label %171

171:                                              ; preds = %1, %169
  %172 = phi i32 [ %170, %169 ], [ -1, %1 ]
  ret i32 %172
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

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn
declare void @free(i8* nocapture noundef) local_unnamed_addr #5

declare i32 @filter_ge_date32(%struct.SimpleColumnView* noundef, i32 noundef, i32* noundef) local_unnamed_addr #2

declare i32 @filter_lt_date32_on_sel(i32* noundef, i32 noundef, %struct.SimpleColumnView* noundef, i32 noundef, i32* noundef) local_unnamed_addr #2

declare i32 @filter_between_i64_on_sel(i32* noundef, i32 noundef, %struct.SimpleColumnView* noundef, i64 noundef, i64 noundef, i32* noundef) local_unnamed_addr #2

declare i32 @filter_lt_i64_on_sel(i32* noundef, i32 noundef, %struct.SimpleColumnView* noundef, i64 noundef, i32* noundef) local_unnamed_addr #2

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
