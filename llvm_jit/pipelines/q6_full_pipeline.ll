; ModuleID = 'q6_full_pipeline.c'
source_filename = "q6_full_pipeline.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.ScanHandle = type opaque
%struct.ArrowBatch = type { %struct.ArrowArray*, %struct.ArrowSchema*, i64, i32, i8* }
%struct.ArrowArray = type { i64, i64, i64, i64, i64, i8**, %struct.ArrowArray**, %struct.ArrowArray*, void (%struct.ArrowArray*)*, i8* }
%struct.ArrowSchema = type { i8*, i8*, i8*, i64, i64, %struct.ArrowSchema**, %struct.ArrowSchema*, void (%struct.ArrowSchema*)*, i8* }
%struct.ArrowColumnView = type { %struct.ArrowArray*, %struct.ArrowSchema*, i8*, i8*, i32*, i8*, i32, i32, i64, i64 }
%struct.SimpleColumnView = type { i32*, i8*, i64, i64, i32 }
%struct.Q6AggregationState = type { %struct.AVX2DoubleSumBuffer* }
%struct.AVX2DoubleSumBuffer = type opaque

@.str.2 = private unnamed_addr constant [44 x i8] c"Failed to get required columns in batch %d\0A\00", align 1
@.str.3 = private unnamed_addr constant [53 x i8] c"Batch %d: %lld rows -> %d filtered -> %d aggregated\0A\00", align 1
@.str.6 = private unnamed_addr constant [19 x i8] c"Total batches: %d\0A\00", align 1
@.str.7 = private unnamed_addr constant [26 x i8] c"Total rows scanned: %lld\0A\00", align 1
@.str.8 = private unnamed_addr constant [27 x i8] c"Total rows filtered: %lld\0A\00", align 1
@.str.9 = private unnamed_addr constant [29 x i8] c"Total rows aggregated: %lld\0A\00", align 1
@.str.10 = private unnamed_addr constant [29 x i8] c"Overall selectivity: %.4f%%\0A\00", align 1
@.str.11 = private unnamed_addr constant [23 x i8] c"Error during scan: %d\0A\00", align 1
@str = private unnamed_addr constant [42 x i8] c"Failed to initialize Q6 aggregation state\00", align 1
@str.12 = private unnamed_addr constant [29 x i8] c"=== q6_full JIT Pipeline ===\00", align 1
@str.13 = private unnamed_addr constant [30 x i8] c"\0AFinalizing Q6 aggregation...\00", align 1
@str.14 = private unnamed_addr constant [25 x i8] c"\0A=== q6_full Results ===\00", align 1

; Function Attrs: nounwind uwtable
define dso_local i32 @q6_full_pipeline_jit(%struct.ScanHandle* noundef %0) local_unnamed_addr #0 {
  %2 = alloca %struct.ArrowBatch, align 8
  %3 = alloca %struct.ArrowColumnView, align 8
  %4 = alloca %struct.ArrowColumnView, align 8
  %5 = alloca %struct.ArrowColumnView, align 8
  %6 = alloca %struct.SimpleColumnView, align 8
  %7 = alloca %struct.SimpleColumnView, align 8
  %8 = alloca %struct.SimpleColumnView, align 8
  %9 = icmp eq %struct.ScanHandle* %0, null
  br i1 %9, label %181, label %10

10:                                               ; preds = %1
  %11 = tail call %struct.Q6AggregationState* @q6_agg_init_optimized() #7
  %12 = icmp eq %struct.Q6AggregationState* %11, null
  br i1 %12, label %13, label %15

13:                                               ; preds = %10
  %14 = tail call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([42 x i8], [42 x i8]* @str, i64 0, i64 0))
  br label %181

15:                                               ; preds = %10
  %16 = bitcast %struct.ArrowBatch* %2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %16) #7
  %17 = call i32 @ndb_arrow_batch_init(%struct.ArrowBatch* noundef nonnull %2) #7
  %18 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([29 x i8], [29 x i8]* @str.12, i64 0, i64 0))
  %19 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %20 = icmp sgt i32 %19, 0
  br i1 %20, label %21, label %153

21:                                               ; preds = %15
  %22 = getelementptr inbounds %struct.ArrowBatch, %struct.ArrowBatch* %2, i64 0, i32 2
  %23 = bitcast %struct.ArrowColumnView* %3 to i8*
  %24 = bitcast %struct.ArrowColumnView* %4 to i8*
  %25 = bitcast %struct.ArrowColumnView* %5 to i8*
  %26 = bitcast %struct.SimpleColumnView* %6 to i8*
  %27 = bitcast %struct.SimpleColumnView* %7 to i8*
  %28 = bitcast %struct.SimpleColumnView* %8 to i8*
  %29 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 3
  %30 = bitcast i8** %29 to i32**
  %31 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %6, i64 0, i32 0
  %32 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 2
  %33 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %6, i64 0, i32 1
  %34 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 8
  %35 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %6, i64 0, i32 2
  %36 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %3, i64 0, i32 6
  %37 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %6, i64 0, i32 4
  %38 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %4, i64 0, i32 3
  %39 = bitcast i8** %38 to i32**
  %40 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %7, i64 0, i32 0
  %41 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %4, i64 0, i32 2
  %42 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %7, i64 0, i32 1
  %43 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %4, i64 0, i32 8
  %44 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %7, i64 0, i32 2
  %45 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %4, i64 0, i32 6
  %46 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %7, i64 0, i32 4
  %47 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %5, i64 0, i32 3
  %48 = bitcast i8** %47 to i32**
  %49 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %8, i64 0, i32 0
  %50 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %5, i64 0, i32 2
  %51 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %8, i64 0, i32 1
  %52 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %5, i64 0, i32 8
  %53 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %8, i64 0, i32 2
  %54 = getelementptr inbounds %struct.ArrowColumnView, %struct.ArrowColumnView* %5, i64 0, i32 6
  %55 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %8, i64 0, i32 4
  %56 = getelementptr inbounds %struct.ArrowBatch, %struct.ArrowBatch* %2, i64 0, i32 0
  %57 = bitcast i64* %34 to <2 x i64>*
  %58 = bitcast i64* %35 to <2 x i64>*
  %59 = bitcast i64* %43 to <2 x i64>*
  %60 = bitcast i64* %44 to <2 x i64>*
  %61 = bitcast i64* %52 to <2 x i64>*
  %62 = bitcast i64* %53 to <2 x i64>*
  br label %63

63:                                               ; preds = %21, %148
  %64 = phi i64 [ 0, %21 ], [ %73, %148 ]
  %65 = phi i64 [ 0, %21 ], [ %150, %148 ]
  %66 = phi i64 [ 0, %21 ], [ %149, %148 ]
  %67 = phi i32 [ 0, %21 ], [ %71, %148 ]
  br label %68

68:                                               ; preds = %63, %75
  %69 = phi i64 [ %64, %63 ], [ %73, %75 ]
  %70 = phi i32 [ %67, %63 ], [ %71, %75 ]
  %71 = add nsw i32 %70, 1
  %72 = load i64, i64* %22, align 8, !tbaa !5
  %73 = add nsw i64 %72, %69
  %74 = icmp eq i64 %72, 0
  br i1 %74, label %75, label %78

75:                                               ; preds = %68
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  %76 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %77 = icmp sgt i32 %76, 0
  br i1 %77, label %68, label %153, !llvm.loop !12

78:                                               ; preds = %68
  call void @llvm.lifetime.start.p0i8(i64 72, i8* nonnull %23) #7
  call void @llvm.lifetime.start.p0i8(i64 72, i8* nonnull %24) #7
  call void @llvm.lifetime.start.p0i8(i64 72, i8* nonnull %25) #7
  %79 = call i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef nonnull %2, i32 noundef 3, %struct.ArrowColumnView* noundef nonnull %3) #7
  %80 = icmp eq i32 %79, 0
  br i1 %80, label %81, label %87

81:                                               ; preds = %78
  %82 = call i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef nonnull %2, i32 noundef 2, %struct.ArrowColumnView* noundef nonnull %4) #7
  %83 = icmp eq i32 %82, 0
  br i1 %83, label %84, label %87

84:                                               ; preds = %81
  %85 = call i32 @ndb_get_arrow_column(%struct.ArrowBatch* noundef nonnull %2, i32 noundef 0, %struct.ArrowColumnView* noundef nonnull %5) #7
  %86 = icmp eq i32 %85, 0
  br i1 %86, label %89, label %87

87:                                               ; preds = %84, %81, %78
  %88 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([44 x i8], [44 x i8]* @.str.2, i64 0, i64 0), i32 noundef %71)
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  br label %148, !llvm.loop !12

89:                                               ; preds = %84
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %26) #7
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %27) #7
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %28) #7
  %90 = load i32*, i32** %30, align 8, !tbaa !14
  store i32* %90, i32** %31, align 8, !tbaa !16
  %91 = load i8*, i8** %32, align 8, !tbaa !18
  store i8* %91, i8** %33, align 8, !tbaa !19
  %92 = load <2 x i64>, <2 x i64>* %57, align 8, !tbaa !20
  store <2 x i64> %92, <2 x i64>* %58, align 8, !tbaa !20
  %93 = load i32, i32* %36, align 8, !tbaa !21
  store i32 %93, i32* %37, align 8, !tbaa !22
  %94 = load i32*, i32** %39, align 8, !tbaa !14
  store i32* %94, i32** %40, align 8, !tbaa !16
  %95 = load i8*, i8** %41, align 8, !tbaa !18
  store i8* %95, i8** %42, align 8, !tbaa !19
  %96 = load <2 x i64>, <2 x i64>* %59, align 8, !tbaa !20
  store <2 x i64> %96, <2 x i64>* %60, align 8, !tbaa !20
  %97 = load i32, i32* %45, align 8, !tbaa !21
  store i32 %97, i32* %46, align 8, !tbaa !22
  %98 = load i32*, i32** %48, align 8, !tbaa !14
  store i32* %98, i32** %49, align 8, !tbaa !16
  %99 = load i8*, i8** %50, align 8, !tbaa !18
  store i8* %99, i8** %51, align 8, !tbaa !19
  %100 = load <2 x i64>, <2 x i64>* %61, align 8, !tbaa !20
  store <2 x i64> %100, <2 x i64>* %62, align 8, !tbaa !20
  %101 = load i32, i32* %54, align 8, !tbaa !21
  store i32 %101, i32* %55, align 8, !tbaa !22
  %102 = load i64, i64* %22, align 8, !tbaa !5
  %103 = shl i64 %102, 2
  %104 = call noalias i8* @malloc(i64 noundef %103) #7
  %105 = bitcast i8* %104 to i32*
  %106 = call noalias i8* @malloc(i64 noundef %103) #7
  %107 = bitcast i8* %106 to i32*
  %108 = call noalias i8* @malloc(i64 noundef %103) #7
  %109 = bitcast i8* %108 to i32*
  %110 = call noalias i8* @malloc(i64 noundef %103) #7
  %111 = bitcast i8* %110 to i32*
  %112 = icmp ne i8* %104, null
  %113 = icmp ne i8* %106, null
  %114 = and i1 %112, %113
  %115 = icmp ne i8* %108, null
  %116 = and i1 %114, %115
  %117 = icmp ne i8* %110, null
  %118 = and i1 %116, %117
  br i1 %118, label %120, label %119

119:                                              ; preds = %89
  call void @free(i8* noundef %104) #7
  call void @free(i8* noundef %106) #7
  call void @free(i8* noundef %108) #7
  call void @free(i8* noundef %110) #7
  br label %145, !llvm.loop !12

120:                                              ; preds = %89
  %121 = call i32 @filter_ge_date32(%struct.SimpleColumnView* noundef nonnull %6, i32 noundef 8766, i32* noundef nonnull %107) #7
  %122 = icmp sgt i32 %121, 0
  br i1 %122, label %123, label %142

123:                                              ; preds = %120
  %124 = call i32 @filter_lt_date32_on_sel(i32* noundef nonnull %107, i32 noundef %121, %struct.SimpleColumnView* noundef nonnull %6, i32 noundef 9131, i32* noundef nonnull %109) #7
  %125 = icmp sgt i32 %124, 0
  br i1 %125, label %126, label %142

126:                                              ; preds = %123
  %127 = call i32 @filter_between_i64_on_sel(i32* noundef nonnull %109, i32 noundef %124, %struct.SimpleColumnView* noundef nonnull %7, i64 noundef 5, i64 noundef 7, i32* noundef nonnull %111) #7
  %128 = icmp sgt i32 %127, 0
  br i1 %128, label %129, label %142

129:                                              ; preds = %126
  %130 = call i32 @filter_lt_i64_on_sel(i32* noundef nonnull %111, i32 noundef %127, %struct.SimpleColumnView* noundef nonnull %8, i64 noundef 2400, i32* noundef nonnull %105) #7
  %131 = icmp sgt i32 %130, 0
  br i1 %131, label %132, label %142

132:                                              ; preds = %129
  %133 = zext i32 %130 to i64
  %134 = add nsw i64 %65, %133
  %135 = load %struct.ArrowArray*, %struct.ArrowArray** %56, align 8, !tbaa !23
  call void @q6_agg_process_batch_optimized(%struct.Q6AggregationState* noundef nonnull %11, %struct.ArrowArray* noundef %135, i32* noundef nonnull %105, i32 noundef %130) #7
  %136 = add nsw i64 %66, %133
  %137 = srem i32 %71, 100
  %138 = icmp eq i32 %137, 0
  br i1 %138, label %139, label %142

139:                                              ; preds = %132
  %140 = load i64, i64* %22, align 8, !tbaa !5
  %141 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([53 x i8], [53 x i8]* @.str.3, i64 0, i64 0), i32 noundef %71, i64 noundef %140, i32 noundef %130, i32 noundef %130)
  br label %142

142:                                              ; preds = %126, %123, %120, %132, %139, %129
  %143 = phi i64 [ %136, %139 ], [ %136, %132 ], [ %66, %129 ], [ %66, %120 ], [ %66, %123 ], [ %66, %126 ]
  %144 = phi i64 [ %134, %139 ], [ %134, %132 ], [ %65, %129 ], [ %65, %120 ], [ %65, %123 ], [ %65, %126 ]
  call void @free(i8* noundef nonnull %104) #7
  call void @free(i8* noundef nonnull %106) #7
  call void @free(i8* noundef nonnull %108) #7
  call void @free(i8* noundef nonnull %110) #7
  br label %145

145:                                              ; preds = %142, %119
  %146 = phi i64 [ %143, %142 ], [ %66, %119 ]
  %147 = phi i64 [ %144, %142 ], [ %65, %119 ]
  call void @ndb_arrow_batch_cleanup(%struct.ArrowBatch* noundef nonnull %2) #7
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %28) #7
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %27) #7
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %26) #7
  br label %148

148:                                              ; preds = %145, %87
  %149 = phi i64 [ %66, %87 ], [ %146, %145 ]
  %150 = phi i64 [ %65, %87 ], [ %147, %145 ]
  call void @llvm.lifetime.end.p0i8(i64 72, i8* nonnull %25) #7
  call void @llvm.lifetime.end.p0i8(i64 72, i8* nonnull %24) #7
  call void @llvm.lifetime.end.p0i8(i64 72, i8* nonnull %23) #7
  %151 = call i32 @rt_scan_next(%struct.ScanHandle* noundef nonnull %0, %struct.ArrowBatch* noundef nonnull %2) #7
  %152 = icmp sgt i32 %151, 0
  br i1 %152, label %63, label %153

153:                                              ; preds = %148, %75, %15
  %154 = phi i64 [ 0, %15 ], [ %66, %75 ], [ %149, %148 ]
  %155 = phi i64 [ 0, %15 ], [ %65, %75 ], [ %150, %148 ]
  %156 = phi i32 [ 0, %15 ], [ %71, %75 ], [ %71, %148 ]
  %157 = phi i64 [ 0, %15 ], [ %73, %75 ], [ %73, %148 ]
  %158 = phi i32 [ %19, %15 ], [ %76, %75 ], [ %151, %148 ]
  %159 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([30 x i8], [30 x i8]* @str.13, i64 0, i64 0))
  call void @q6_agg_finalize_optimized(%struct.Q6AggregationState* noundef nonnull %11) #7
  %160 = call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([25 x i8], [25 x i8]* @str.14, i64 0, i64 0))
  %161 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([19 x i8], [19 x i8]* @.str.6, i64 0, i64 0), i32 noundef %156)
  %162 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([26 x i8], [26 x i8]* @.str.7, i64 0, i64 0), i64 noundef %157)
  %163 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([27 x i8], [27 x i8]* @.str.8, i64 0, i64 0), i64 noundef %155)
  %164 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([29 x i8], [29 x i8]* @.str.9, i64 0, i64 0), i64 noundef %154)
  %165 = icmp sgt i64 %157, 0
  br i1 %165, label %166, label %171

166:                                              ; preds = %153
  %167 = sitofp i64 %155 to double
  %168 = fmul double %167, 1.000000e+02
  %169 = sitofp i64 %157 to double
  %170 = fdiv double %168, %169
  br label %171

171:                                              ; preds = %153, %166
  %172 = phi double [ %170, %166 ], [ 0.000000e+00, %153 ]
  %173 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([29 x i8], [29 x i8]* @.str.10, i64 0, i64 0), double noundef %172)
  call void @q6_agg_destroy_optimized(%struct.Q6AggregationState* noundef nonnull %11) #7
  %174 = icmp slt i32 %158, 0
  br i1 %174, label %175, label %177

175:                                              ; preds = %171
  %176 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str.11, i64 0, i64 0), i32 noundef %158)
  br label %179

177:                                              ; preds = %171
  %178 = trunc i64 %154 to i32
  br label %179

179:                                              ; preds = %177, %175
  %180 = phi i32 [ %158, %175 ], [ %178, %177 ]
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %16) #7
  br label %181

181:                                              ; preds = %13, %179, %1
  %182 = phi i32 [ -1, %1 ], [ %180, %179 ], [ -1, %13 ]
  ret i32 %182
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare %struct.Q6AggregationState* @q6_agg_init_optimized() local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #3

declare i32 @ndb_arrow_batch_init(%struct.ArrowBatch* noundef) local_unnamed_addr #2

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

declare void @q6_agg_process_batch_optimized(%struct.Q6AggregationState* noundef, %struct.ArrowArray* noundef, i32* noundef, i32 noundef) local_unnamed_addr #2

declare void @q6_agg_finalize_optimized(%struct.Q6AggregationState* noundef) local_unnamed_addr #2

declare void @q6_agg_destroy_optimized(%struct.Q6AggregationState* noundef) local_unnamed_addr #2

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
