; ModuleID = 'q1_incremental.c'
source_filename = "q1_incremental.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Q1AggregationState = type { %struct.Q1HashTable, i8 }
%struct.Q1HashTable = type { [1024 x %struct.Q1HashEntry], i32 }
%struct.Q1HashEntry = type { i8, i8, i64, i64, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer*, double, double, double, double, double }
%struct.AVX2DoubleSumBuffer = type opaque
%struct.ArrowArray = type { i64, i64, i64, i64, i64, i8**, %struct.ArrowArray**, %struct.ArrowArray*, void (%struct.ArrowArray*)*, i8* }
%struct.AVX2DoubleSumBuffer.0 = type { double*, i32, i32 }

@.str.1 = private unnamed_addr constant [54 x i8] c"%-15s %-15s %-8s %-15s %-15s %-15s %-15s %-15s %-15s\0A\00", align 1
@.str.2 = private unnamed_addr constant [13 x i8] c"l_returnflag\00", align 1
@.str.3 = private unnamed_addr constant [13 x i8] c"l_linestatus\00", align 1
@.str.4 = private unnamed_addr constant [6 x i8] c"count\00", align 1
@.str.5 = private unnamed_addr constant [8 x i8] c"sum_qty\00", align 1
@.str.6 = private unnamed_addr constant [10 x i8] c"sum_price\00", align 1
@.str.7 = private unnamed_addr constant [15 x i8] c"sum_disc_price\00", align 1
@.str.8 = private unnamed_addr constant [11 x i8] c"sum_charge\00", align 1
@.str.9 = private unnamed_addr constant [8 x i8] c"avg_qty\00", align 1
@.str.10 = private unnamed_addr constant [9 x i8] c"avg_disc\00", align 1
@.str.11 = private unnamed_addr constant [68 x i8] c"%-15c %-15c %-8lld %-15.2f %-15.2f %-15.2f %-15.2f %-15.2f %-15.2f\0A\00", align 1
@str = private unnamed_addr constant [29 x i8] c"\0A=== Aggregation Results ===\00", align 1
@str.13 = private unnamed_addr constant [28 x i8] c"===========================\00", align 1

; Function Attrs: mustprogress nofree nounwind uwtable willreturn
define dso_local noalias %struct.Q1AggregationState* @q1_agg_init() local_unnamed_addr #0 {
  %1 = tail call noalias dereferenceable_or_null(106512) i8* @malloc(i64 noundef 106512) #11
  %2 = icmp eq i8* %1, null
  br i1 %2, label %4, label %3

3:                                                ; preds = %0
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 8 dereferenceable(106505) %1, i8 0, i64 106505, i1 false)
  br label %4

4:                                                ; preds = %3, %0
  %5 = bitcast i8* %1 to %struct.Q1AggregationState*
  ret %struct.Q1AggregationState* %5
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn
declare noalias noundef i8* @malloc(i64 noundef) local_unnamed_addr #2

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind uwtable
define dso_local void @q1_agg_process_batch(%struct.Q1AggregationState* noundef %0, %struct.ArrowArray* nocapture noundef readonly %1, i32* nocapture noundef readonly %2, i32 noundef %3) local_unnamed_addr #4 {
  %5 = alloca [2 x i8], align 1
  %6 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 1
  %7 = load i8, i8* %6, align 8, !tbaa !5, !range !12
  %8 = icmp eq i8 %7, 0
  %9 = icmp sgt i32 %3, 0
  %10 = and i1 %8, %9
  br i1 %10, label %11, label %518

11:                                               ; preds = %4
  %12 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %1, i64 0, i32 6
  %13 = getelementptr inbounds [2 x i8], [2 x i8]* %5, i64 0, i64 0
  %14 = getelementptr inbounds [2 x i8], [2 x i8]* %5, i64 0, i64 1
  %15 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 1
  %16 = zext i32 %3 to i64
  br label %17

17:                                               ; preds = %11, %492
  %18 = phi i64 [ 0, %11 ], [ %516, %492 ]
  %19 = getelementptr inbounds i32, i32* %2, i64 %18
  %20 = load i32, i32* %19, align 4, !tbaa !13
  %21 = sext i32 %20 to i64
  %22 = load %struct.ArrowArray**, %struct.ArrowArray*** %12, align 8, !tbaa !14
  %23 = getelementptr inbounds %struct.ArrowArray*, %struct.ArrowArray** %22, i64 1
  %24 = load %struct.ArrowArray*, %struct.ArrowArray** %23, align 8, !tbaa !18
  %25 = icmp eq %struct.ArrowArray* %24, null
  br i1 %25, label %52, label %26

26:                                               ; preds = %17
  %27 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %24, i64 0, i32 5
  %28 = load i8**, i8*** %27, align 8, !tbaa !19
  %29 = getelementptr inbounds i8*, i8** %28, i64 1
  %30 = load i8*, i8** %29, align 8, !tbaa !18
  %31 = icmp eq i8* %30, null
  br i1 %31, label %52, label %32

32:                                               ; preds = %26
  %33 = getelementptr inbounds i8*, i8** %28, i64 2
  %34 = load i8*, i8** %33, align 8, !tbaa !18
  %35 = icmp eq i8* %34, null
  br i1 %35, label %52, label %36

36:                                               ; preds = %32
  %37 = bitcast i8* %30 to i32*
  %38 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %24, i64 0, i32 0
  %39 = load i64, i64* %38, align 8, !tbaa !20
  %40 = icmp sgt i64 %39, %21
  br i1 %40, label %41, label %52

41:                                               ; preds = %36
  %42 = getelementptr inbounds i32, i32* %37, i64 %21
  %43 = load i32, i32* %42, align 4, !tbaa !13
  %44 = add nsw i64 %21, 1
  %45 = getelementptr inbounds i32, i32* %37, i64 %44
  %46 = load i32, i32* %45, align 4, !tbaa !13
  %47 = icmp sgt i32 %46, %43
  br i1 %47, label %48, label %52

48:                                               ; preds = %41
  %49 = sext i32 %43 to i64
  %50 = getelementptr inbounds i8, i8* %34, i64 %49
  %51 = load i8, i8* %50, align 1, !tbaa !21
  br label %52

52:                                               ; preds = %17, %26, %32, %36, %41, %48
  %53 = phi i8 [ 63, %32 ], [ 63, %26 ], [ 63, %17 ], [ 63, %36 ], [ %51, %48 ], [ 63, %41 ]
  %54 = getelementptr inbounds %struct.ArrowArray*, %struct.ArrowArray** %22, i64 2
  %55 = load %struct.ArrowArray*, %struct.ArrowArray** %54, align 8, !tbaa !18
  %56 = icmp eq %struct.ArrowArray* %55, null
  br i1 %56, label %83, label %57

57:                                               ; preds = %52
  %58 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %55, i64 0, i32 5
  %59 = load i8**, i8*** %58, align 8, !tbaa !19
  %60 = getelementptr inbounds i8*, i8** %59, i64 1
  %61 = load i8*, i8** %60, align 8, !tbaa !18
  %62 = icmp eq i8* %61, null
  br i1 %62, label %83, label %63

63:                                               ; preds = %57
  %64 = getelementptr inbounds i8*, i8** %59, i64 2
  %65 = load i8*, i8** %64, align 8, !tbaa !18
  %66 = icmp eq i8* %65, null
  br i1 %66, label %83, label %67

67:                                               ; preds = %63
  %68 = bitcast i8* %61 to i32*
  %69 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %55, i64 0, i32 0
  %70 = load i64, i64* %69, align 8, !tbaa !20
  %71 = icmp sgt i64 %70, %21
  br i1 %71, label %72, label %83

72:                                               ; preds = %67
  %73 = getelementptr inbounds i32, i32* %68, i64 %21
  %74 = load i32, i32* %73, align 4, !tbaa !13
  %75 = add nsw i64 %21, 1
  %76 = getelementptr inbounds i32, i32* %68, i64 %75
  %77 = load i32, i32* %76, align 4, !tbaa !13
  %78 = icmp sgt i32 %77, %74
  br i1 %78, label %79, label %83

79:                                               ; preds = %72
  %80 = sext i32 %74 to i64
  %81 = getelementptr inbounds i8, i8* %65, i64 %80
  %82 = load i8, i8* %81, align 1, !tbaa !21
  br label %83

83:                                               ; preds = %52, %57, %63, %67, %72, %79
  %84 = phi i8 [ 63, %63 ], [ 63, %57 ], [ 63, %52 ], [ 63, %67 ], [ %82, %79 ], [ 63, %72 ]
  call void @llvm.lifetime.start.p0i8(i64 2, i8* nonnull %13) #11
  store i8 %53, i8* %13, align 1, !tbaa !21
  store i8 %84, i8* %14, align 1, !tbaa !21
  %85 = call i64 @XXH3_64bits(i8* nocapture noundef nonnull %13, i64 noundef 2) #12
  call void @llvm.lifetime.end.p0i8(i64 2, i8* nonnull %13) #11
  %86 = load i32, i32* %15, align 8, !tbaa !22
  %87 = icmp sgt i32 %86, 0
  br i1 %87, label %88, label %101

88:                                               ; preds = %83
  %89 = zext i32 %86 to i64
  br label %90

90:                                               ; preds = %88, %95
  %91 = phi i64 [ 0, %88 ], [ %96, %95 ]
  %92 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %91, i32 2
  %93 = load i64, i64* %92, align 8, !tbaa !23
  %94 = icmp eq i64 %93, %85
  br i1 %94, label %98, label %95

95:                                               ; preds = %90
  %96 = add nuw nsw i64 %91, 1
  %97 = icmp eq i64 %96, %89
  br i1 %97, label %101, label %90, !llvm.loop !26

98:                                               ; preds = %90
  %99 = and i64 %91, 4294967295
  %100 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %99
  br label %127

101:                                              ; preds = %95, %83
  %102 = add nsw i32 %86, 1
  store i32 %102, i32* %15, align 8, !tbaa !22
  %103 = sext i32 %86 to i64
  %104 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %103
  %105 = getelementptr inbounds %struct.Q1HashEntry, %struct.Q1HashEntry* %104, i64 0, i32 0
  store i8 %53, i8* %105, align 8, !tbaa !28
  %106 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %103, i32 1
  store i8 %84, i8* %106, align 1, !tbaa !29
  %107 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %103, i32 2
  store i64 %85, i64* %107, align 8, !tbaa !23
  %108 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %103, i32 3
  store i64 0, i64* %108, align 8, !tbaa !30
  %109 = tail call %struct.AVX2DoubleSumBuffer.0* @avx2_double_sum_create(i32 noundef 512) #11
  %110 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %103, i32 4
  %111 = bitcast %struct.AVX2DoubleSumBuffer** %110 to %struct.AVX2DoubleSumBuffer.0**
  store %struct.AVX2DoubleSumBuffer.0* %109, %struct.AVX2DoubleSumBuffer.0** %111, align 8, !tbaa !31
  %112 = tail call %struct.AVX2DoubleSumBuffer.0* @avx2_double_sum_create(i32 noundef 512) #11
  %113 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %103, i32 5
  %114 = bitcast %struct.AVX2DoubleSumBuffer** %113 to %struct.AVX2DoubleSumBuffer.0**
  store %struct.AVX2DoubleSumBuffer.0* %112, %struct.AVX2DoubleSumBuffer.0** %114, align 8, !tbaa !32
  %115 = tail call %struct.AVX2DoubleSumBuffer.0* @avx2_double_sum_create(i32 noundef 512) #11
  %116 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %103, i32 6
  %117 = bitcast %struct.AVX2DoubleSumBuffer** %116 to %struct.AVX2DoubleSumBuffer.0**
  store %struct.AVX2DoubleSumBuffer.0* %115, %struct.AVX2DoubleSumBuffer.0** %117, align 8, !tbaa !33
  %118 = tail call %struct.AVX2DoubleSumBuffer.0* @avx2_double_sum_create(i32 noundef 512) #11
  %119 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %103, i32 7
  %120 = bitcast %struct.AVX2DoubleSumBuffer** %119 to %struct.AVX2DoubleSumBuffer.0**
  store %struct.AVX2DoubleSumBuffer.0* %118, %struct.AVX2DoubleSumBuffer.0** %120, align 8, !tbaa !34
  %121 = tail call %struct.AVX2DoubleSumBuffer.0* @avx2_double_sum_create(i32 noundef 512) #11
  %122 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %103, i32 8
  %123 = bitcast %struct.AVX2DoubleSumBuffer** %122 to %struct.AVX2DoubleSumBuffer.0**
  store %struct.AVX2DoubleSumBuffer.0* %121, %struct.AVX2DoubleSumBuffer.0** %123, align 8, !tbaa !35
  %124 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %103, i32 9
  %125 = bitcast double* %124 to i8*
  tail call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 8 dereferenceable(40) %125, i8 0, i64 40, i1 false) #11
  %126 = load %struct.ArrowArray**, %struct.ArrowArray*** %12, align 8, !tbaa !14
  br label %127

127:                                              ; preds = %98, %101
  %128 = phi %struct.ArrowArray** [ %22, %98 ], [ %126, %101 ]
  %129 = phi %struct.Q1HashEntry* [ %100, %98 ], [ %104, %101 ]
  %130 = getelementptr inbounds %struct.ArrowArray*, %struct.ArrowArray** %128, i64 3
  %131 = load %struct.ArrowArray*, %struct.ArrowArray** %130, align 8, !tbaa !18
  %132 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %131, i64 0, i32 5
  %133 = load i8**, i8*** %132, align 8, !tbaa !19
  %134 = getelementptr inbounds i8*, i8** %133, i64 1
  %135 = load i8*, i8** %134, align 8, !tbaa !18
  %136 = icmp eq i8* %135, null
  br i1 %136, label %219, label %137

137:                                              ; preds = %127
  %138 = shl nsw i64 %21, 4
  %139 = getelementptr inbounds i8, i8* %135, i64 %138
  %140 = load i8, i8* %139, align 1, !tbaa !21
  %141 = zext i8 %140 to i128
  %142 = getelementptr inbounds i8, i8* %139, i64 1
  %143 = load i8, i8* %142, align 1, !tbaa !21
  %144 = zext i8 %143 to i128
  %145 = shl nuw nsw i128 %144, 8
  %146 = or i128 %145, %141
  %147 = getelementptr inbounds i8, i8* %139, i64 2
  %148 = load i8, i8* %147, align 1, !tbaa !21
  %149 = zext i8 %148 to i128
  %150 = shl nuw nsw i128 %149, 16
  %151 = or i128 %150, %146
  %152 = getelementptr inbounds i8, i8* %139, i64 3
  %153 = load i8, i8* %152, align 1, !tbaa !21
  %154 = zext i8 %153 to i128
  %155 = shl nuw nsw i128 %154, 24
  %156 = or i128 %155, %151
  %157 = getelementptr inbounds i8, i8* %139, i64 4
  %158 = load i8, i8* %157, align 1, !tbaa !21
  %159 = zext i8 %158 to i128
  %160 = shl nuw nsw i128 %159, 32
  %161 = or i128 %160, %156
  %162 = getelementptr inbounds i8, i8* %139, i64 5
  %163 = load i8, i8* %162, align 1, !tbaa !21
  %164 = zext i8 %163 to i128
  %165 = shl nuw nsw i128 %164, 40
  %166 = or i128 %165, %161
  %167 = getelementptr inbounds i8, i8* %139, i64 6
  %168 = load i8, i8* %167, align 1, !tbaa !21
  %169 = zext i8 %168 to i128
  %170 = shl nuw nsw i128 %169, 48
  %171 = or i128 %170, %166
  %172 = getelementptr inbounds i8, i8* %139, i64 7
  %173 = load i8, i8* %172, align 1, !tbaa !21
  %174 = zext i8 %173 to i128
  %175 = shl nuw nsw i128 %174, 56
  %176 = or i128 %175, %171
  %177 = getelementptr inbounds i8, i8* %139, i64 8
  %178 = load i8, i8* %177, align 1, !tbaa !21
  %179 = zext i8 %178 to i128
  %180 = shl nuw nsw i128 %179, 64
  %181 = or i128 %180, %176
  %182 = getelementptr inbounds i8, i8* %139, i64 9
  %183 = load i8, i8* %182, align 1, !tbaa !21
  %184 = zext i8 %183 to i128
  %185 = shl nuw nsw i128 %184, 72
  %186 = or i128 %185, %181
  %187 = getelementptr inbounds i8, i8* %139, i64 10
  %188 = load i8, i8* %187, align 1, !tbaa !21
  %189 = zext i8 %188 to i128
  %190 = shl nuw nsw i128 %189, 80
  %191 = or i128 %190, %186
  %192 = getelementptr inbounds i8, i8* %139, i64 11
  %193 = load i8, i8* %192, align 1, !tbaa !21
  %194 = zext i8 %193 to i128
  %195 = shl nuw nsw i128 %194, 88
  %196 = or i128 %195, %191
  %197 = getelementptr inbounds i8, i8* %139, i64 12
  %198 = load i8, i8* %197, align 1, !tbaa !21
  %199 = zext i8 %198 to i128
  %200 = shl nuw nsw i128 %199, 96
  %201 = or i128 %200, %196
  %202 = getelementptr inbounds i8, i8* %139, i64 13
  %203 = load i8, i8* %202, align 1, !tbaa !21
  %204 = zext i8 %203 to i128
  %205 = shl nuw nsw i128 %204, 104
  %206 = or i128 %205, %201
  %207 = getelementptr inbounds i8, i8* %139, i64 14
  %208 = load i8, i8* %207, align 1, !tbaa !21
  %209 = zext i8 %208 to i128
  %210 = shl nuw nsw i128 %209, 112
  %211 = or i128 %210, %206
  %212 = getelementptr inbounds i8, i8* %139, i64 15
  %213 = load i8, i8* %212, align 1, !tbaa !21
  %214 = zext i8 %213 to i128
  %215 = shl nuw i128 %214, 120
  %216 = or i128 %215, %211
  %217 = sitofp i128 %216 to double
  %218 = fmul double %217, 1.000000e-02
  br label %219

219:                                              ; preds = %137, %127
  %220 = phi double [ %218, %137 ], [ 0.000000e+00, %127 ]
  %221 = getelementptr inbounds %struct.ArrowArray*, %struct.ArrowArray** %128, i64 4
  %222 = load %struct.ArrowArray*, %struct.ArrowArray** %221, align 8, !tbaa !18
  %223 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %222, i64 0, i32 5
  %224 = load i8**, i8*** %223, align 8, !tbaa !19
  %225 = getelementptr inbounds i8*, i8** %224, i64 1
  %226 = load i8*, i8** %225, align 8, !tbaa !18
  %227 = icmp eq i8* %226, null
  br i1 %227, label %310, label %228

228:                                              ; preds = %219
  %229 = shl nsw i64 %21, 4
  %230 = getelementptr inbounds i8, i8* %226, i64 %229
  %231 = load i8, i8* %230, align 1, !tbaa !21
  %232 = zext i8 %231 to i128
  %233 = getelementptr inbounds i8, i8* %230, i64 1
  %234 = load i8, i8* %233, align 1, !tbaa !21
  %235 = zext i8 %234 to i128
  %236 = shl nuw nsw i128 %235, 8
  %237 = or i128 %236, %232
  %238 = getelementptr inbounds i8, i8* %230, i64 2
  %239 = load i8, i8* %238, align 1, !tbaa !21
  %240 = zext i8 %239 to i128
  %241 = shl nuw nsw i128 %240, 16
  %242 = or i128 %241, %237
  %243 = getelementptr inbounds i8, i8* %230, i64 3
  %244 = load i8, i8* %243, align 1, !tbaa !21
  %245 = zext i8 %244 to i128
  %246 = shl nuw nsw i128 %245, 24
  %247 = or i128 %246, %242
  %248 = getelementptr inbounds i8, i8* %230, i64 4
  %249 = load i8, i8* %248, align 1, !tbaa !21
  %250 = zext i8 %249 to i128
  %251 = shl nuw nsw i128 %250, 32
  %252 = or i128 %251, %247
  %253 = getelementptr inbounds i8, i8* %230, i64 5
  %254 = load i8, i8* %253, align 1, !tbaa !21
  %255 = zext i8 %254 to i128
  %256 = shl nuw nsw i128 %255, 40
  %257 = or i128 %256, %252
  %258 = getelementptr inbounds i8, i8* %230, i64 6
  %259 = load i8, i8* %258, align 1, !tbaa !21
  %260 = zext i8 %259 to i128
  %261 = shl nuw nsw i128 %260, 48
  %262 = or i128 %261, %257
  %263 = getelementptr inbounds i8, i8* %230, i64 7
  %264 = load i8, i8* %263, align 1, !tbaa !21
  %265 = zext i8 %264 to i128
  %266 = shl nuw nsw i128 %265, 56
  %267 = or i128 %266, %262
  %268 = getelementptr inbounds i8, i8* %230, i64 8
  %269 = load i8, i8* %268, align 1, !tbaa !21
  %270 = zext i8 %269 to i128
  %271 = shl nuw nsw i128 %270, 64
  %272 = or i128 %271, %267
  %273 = getelementptr inbounds i8, i8* %230, i64 9
  %274 = load i8, i8* %273, align 1, !tbaa !21
  %275 = zext i8 %274 to i128
  %276 = shl nuw nsw i128 %275, 72
  %277 = or i128 %276, %272
  %278 = getelementptr inbounds i8, i8* %230, i64 10
  %279 = load i8, i8* %278, align 1, !tbaa !21
  %280 = zext i8 %279 to i128
  %281 = shl nuw nsw i128 %280, 80
  %282 = or i128 %281, %277
  %283 = getelementptr inbounds i8, i8* %230, i64 11
  %284 = load i8, i8* %283, align 1, !tbaa !21
  %285 = zext i8 %284 to i128
  %286 = shl nuw nsw i128 %285, 88
  %287 = or i128 %286, %282
  %288 = getelementptr inbounds i8, i8* %230, i64 12
  %289 = load i8, i8* %288, align 1, !tbaa !21
  %290 = zext i8 %289 to i128
  %291 = shl nuw nsw i128 %290, 96
  %292 = or i128 %291, %287
  %293 = getelementptr inbounds i8, i8* %230, i64 13
  %294 = load i8, i8* %293, align 1, !tbaa !21
  %295 = zext i8 %294 to i128
  %296 = shl nuw nsw i128 %295, 104
  %297 = or i128 %296, %292
  %298 = getelementptr inbounds i8, i8* %230, i64 14
  %299 = load i8, i8* %298, align 1, !tbaa !21
  %300 = zext i8 %299 to i128
  %301 = shl nuw nsw i128 %300, 112
  %302 = or i128 %301, %297
  %303 = getelementptr inbounds i8, i8* %230, i64 15
  %304 = load i8, i8* %303, align 1, !tbaa !21
  %305 = zext i8 %304 to i128
  %306 = shl nuw i128 %305, 120
  %307 = or i128 %306, %302
  %308 = sitofp i128 %307 to double
  %309 = fmul double %308, 1.000000e-02
  br label %310

310:                                              ; preds = %228, %219
  %311 = phi double [ %309, %228 ], [ 0.000000e+00, %219 ]
  %312 = getelementptr inbounds %struct.ArrowArray*, %struct.ArrowArray** %128, i64 5
  %313 = load %struct.ArrowArray*, %struct.ArrowArray** %312, align 8, !tbaa !18
  %314 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %313, i64 0, i32 5
  %315 = load i8**, i8*** %314, align 8, !tbaa !19
  %316 = getelementptr inbounds i8*, i8** %315, i64 1
  %317 = load i8*, i8** %316, align 8, !tbaa !18
  %318 = icmp eq i8* %317, null
  br i1 %318, label %401, label %319

319:                                              ; preds = %310
  %320 = shl nsw i64 %21, 4
  %321 = getelementptr inbounds i8, i8* %317, i64 %320
  %322 = load i8, i8* %321, align 1, !tbaa !21
  %323 = zext i8 %322 to i128
  %324 = getelementptr inbounds i8, i8* %321, i64 1
  %325 = load i8, i8* %324, align 1, !tbaa !21
  %326 = zext i8 %325 to i128
  %327 = shl nuw nsw i128 %326, 8
  %328 = or i128 %327, %323
  %329 = getelementptr inbounds i8, i8* %321, i64 2
  %330 = load i8, i8* %329, align 1, !tbaa !21
  %331 = zext i8 %330 to i128
  %332 = shl nuw nsw i128 %331, 16
  %333 = or i128 %332, %328
  %334 = getelementptr inbounds i8, i8* %321, i64 3
  %335 = load i8, i8* %334, align 1, !tbaa !21
  %336 = zext i8 %335 to i128
  %337 = shl nuw nsw i128 %336, 24
  %338 = or i128 %337, %333
  %339 = getelementptr inbounds i8, i8* %321, i64 4
  %340 = load i8, i8* %339, align 1, !tbaa !21
  %341 = zext i8 %340 to i128
  %342 = shl nuw nsw i128 %341, 32
  %343 = or i128 %342, %338
  %344 = getelementptr inbounds i8, i8* %321, i64 5
  %345 = load i8, i8* %344, align 1, !tbaa !21
  %346 = zext i8 %345 to i128
  %347 = shl nuw nsw i128 %346, 40
  %348 = or i128 %347, %343
  %349 = getelementptr inbounds i8, i8* %321, i64 6
  %350 = load i8, i8* %349, align 1, !tbaa !21
  %351 = zext i8 %350 to i128
  %352 = shl nuw nsw i128 %351, 48
  %353 = or i128 %352, %348
  %354 = getelementptr inbounds i8, i8* %321, i64 7
  %355 = load i8, i8* %354, align 1, !tbaa !21
  %356 = zext i8 %355 to i128
  %357 = shl nuw nsw i128 %356, 56
  %358 = or i128 %357, %353
  %359 = getelementptr inbounds i8, i8* %321, i64 8
  %360 = load i8, i8* %359, align 1, !tbaa !21
  %361 = zext i8 %360 to i128
  %362 = shl nuw nsw i128 %361, 64
  %363 = or i128 %362, %358
  %364 = getelementptr inbounds i8, i8* %321, i64 9
  %365 = load i8, i8* %364, align 1, !tbaa !21
  %366 = zext i8 %365 to i128
  %367 = shl nuw nsw i128 %366, 72
  %368 = or i128 %367, %363
  %369 = getelementptr inbounds i8, i8* %321, i64 10
  %370 = load i8, i8* %369, align 1, !tbaa !21
  %371 = zext i8 %370 to i128
  %372 = shl nuw nsw i128 %371, 80
  %373 = or i128 %372, %368
  %374 = getelementptr inbounds i8, i8* %321, i64 11
  %375 = load i8, i8* %374, align 1, !tbaa !21
  %376 = zext i8 %375 to i128
  %377 = shl nuw nsw i128 %376, 88
  %378 = or i128 %377, %373
  %379 = getelementptr inbounds i8, i8* %321, i64 12
  %380 = load i8, i8* %379, align 1, !tbaa !21
  %381 = zext i8 %380 to i128
  %382 = shl nuw nsw i128 %381, 96
  %383 = or i128 %382, %378
  %384 = getelementptr inbounds i8, i8* %321, i64 13
  %385 = load i8, i8* %384, align 1, !tbaa !21
  %386 = zext i8 %385 to i128
  %387 = shl nuw nsw i128 %386, 104
  %388 = or i128 %387, %383
  %389 = getelementptr inbounds i8, i8* %321, i64 14
  %390 = load i8, i8* %389, align 1, !tbaa !21
  %391 = zext i8 %390 to i128
  %392 = shl nuw nsw i128 %391, 112
  %393 = or i128 %392, %388
  %394 = getelementptr inbounds i8, i8* %321, i64 15
  %395 = load i8, i8* %394, align 1, !tbaa !21
  %396 = zext i8 %395 to i128
  %397 = shl nuw i128 %396, 120
  %398 = or i128 %397, %393
  %399 = sitofp i128 %398 to double
  %400 = fmul double %399, 1.000000e-02
  br label %401

401:                                              ; preds = %319, %310
  %402 = phi double [ %400, %319 ], [ 0.000000e+00, %310 ]
  %403 = getelementptr inbounds %struct.ArrowArray*, %struct.ArrowArray** %128, i64 6
  %404 = load %struct.ArrowArray*, %struct.ArrowArray** %403, align 8, !tbaa !18
  %405 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %404, i64 0, i32 5
  %406 = load i8**, i8*** %405, align 8, !tbaa !19
  %407 = getelementptr inbounds i8*, i8** %406, i64 1
  %408 = load i8*, i8** %407, align 8, !tbaa !18
  %409 = icmp eq i8* %408, null
  br i1 %409, label %492, label %410

410:                                              ; preds = %401
  %411 = shl nsw i64 %21, 4
  %412 = getelementptr inbounds i8, i8* %408, i64 %411
  %413 = load i8, i8* %412, align 1, !tbaa !21
  %414 = zext i8 %413 to i128
  %415 = getelementptr inbounds i8, i8* %412, i64 1
  %416 = load i8, i8* %415, align 1, !tbaa !21
  %417 = zext i8 %416 to i128
  %418 = shl nuw nsw i128 %417, 8
  %419 = or i128 %418, %414
  %420 = getelementptr inbounds i8, i8* %412, i64 2
  %421 = load i8, i8* %420, align 1, !tbaa !21
  %422 = zext i8 %421 to i128
  %423 = shl nuw nsw i128 %422, 16
  %424 = or i128 %423, %419
  %425 = getelementptr inbounds i8, i8* %412, i64 3
  %426 = load i8, i8* %425, align 1, !tbaa !21
  %427 = zext i8 %426 to i128
  %428 = shl nuw nsw i128 %427, 24
  %429 = or i128 %428, %424
  %430 = getelementptr inbounds i8, i8* %412, i64 4
  %431 = load i8, i8* %430, align 1, !tbaa !21
  %432 = zext i8 %431 to i128
  %433 = shl nuw nsw i128 %432, 32
  %434 = or i128 %433, %429
  %435 = getelementptr inbounds i8, i8* %412, i64 5
  %436 = load i8, i8* %435, align 1, !tbaa !21
  %437 = zext i8 %436 to i128
  %438 = shl nuw nsw i128 %437, 40
  %439 = or i128 %438, %434
  %440 = getelementptr inbounds i8, i8* %412, i64 6
  %441 = load i8, i8* %440, align 1, !tbaa !21
  %442 = zext i8 %441 to i128
  %443 = shl nuw nsw i128 %442, 48
  %444 = or i128 %443, %439
  %445 = getelementptr inbounds i8, i8* %412, i64 7
  %446 = load i8, i8* %445, align 1, !tbaa !21
  %447 = zext i8 %446 to i128
  %448 = shl nuw nsw i128 %447, 56
  %449 = or i128 %448, %444
  %450 = getelementptr inbounds i8, i8* %412, i64 8
  %451 = load i8, i8* %450, align 1, !tbaa !21
  %452 = zext i8 %451 to i128
  %453 = shl nuw nsw i128 %452, 64
  %454 = or i128 %453, %449
  %455 = getelementptr inbounds i8, i8* %412, i64 9
  %456 = load i8, i8* %455, align 1, !tbaa !21
  %457 = zext i8 %456 to i128
  %458 = shl nuw nsw i128 %457, 72
  %459 = or i128 %458, %454
  %460 = getelementptr inbounds i8, i8* %412, i64 10
  %461 = load i8, i8* %460, align 1, !tbaa !21
  %462 = zext i8 %461 to i128
  %463 = shl nuw nsw i128 %462, 80
  %464 = or i128 %463, %459
  %465 = getelementptr inbounds i8, i8* %412, i64 11
  %466 = load i8, i8* %465, align 1, !tbaa !21
  %467 = zext i8 %466 to i128
  %468 = shl nuw nsw i128 %467, 88
  %469 = or i128 %468, %464
  %470 = getelementptr inbounds i8, i8* %412, i64 12
  %471 = load i8, i8* %470, align 1, !tbaa !21
  %472 = zext i8 %471 to i128
  %473 = shl nuw nsw i128 %472, 96
  %474 = or i128 %473, %469
  %475 = getelementptr inbounds i8, i8* %412, i64 13
  %476 = load i8, i8* %475, align 1, !tbaa !21
  %477 = zext i8 %476 to i128
  %478 = shl nuw nsw i128 %477, 104
  %479 = or i128 %478, %474
  %480 = getelementptr inbounds i8, i8* %412, i64 14
  %481 = load i8, i8* %480, align 1, !tbaa !21
  %482 = zext i8 %481 to i128
  %483 = shl nuw nsw i128 %482, 112
  %484 = or i128 %483, %479
  %485 = getelementptr inbounds i8, i8* %412, i64 15
  %486 = load i8, i8* %485, align 1, !tbaa !21
  %487 = zext i8 %486 to i128
  %488 = shl nuw i128 %487, 120
  %489 = or i128 %488, %484
  %490 = sitofp i128 %489 to double
  %491 = fmul double %490, 1.000000e-02
  br label %492

492:                                              ; preds = %410, %401
  %493 = phi double [ %491, %410 ], [ 0.000000e+00, %401 ]
  %494 = fsub double 1.000000e+00, %402
  %495 = fmul double %311, %494
  %496 = fadd double %493, 1.000000e+00
  %497 = fmul double %495, %496
  %498 = getelementptr inbounds %struct.Q1HashEntry, %struct.Q1HashEntry* %129, i64 0, i32 3
  %499 = load i64, i64* %498, align 8, !tbaa !30
  %500 = add nsw i64 %499, 1
  store i64 %500, i64* %498, align 8, !tbaa !30
  %501 = getelementptr inbounds %struct.Q1HashEntry, %struct.Q1HashEntry* %129, i64 0, i32 4
  %502 = bitcast %struct.AVX2DoubleSumBuffer** %501 to %struct.AVX2DoubleSumBuffer.0**
  %503 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %502, align 8, !tbaa !31
  tail call void @avx2_double_sum_add(%struct.AVX2DoubleSumBuffer.0* noundef %503, double noundef %220) #11
  %504 = getelementptr inbounds %struct.Q1HashEntry, %struct.Q1HashEntry* %129, i64 0, i32 5
  %505 = bitcast %struct.AVX2DoubleSumBuffer** %504 to %struct.AVX2DoubleSumBuffer.0**
  %506 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %505, align 8, !tbaa !32
  tail call void @avx2_double_sum_add(%struct.AVX2DoubleSumBuffer.0* noundef %506, double noundef %311) #11
  %507 = getelementptr inbounds %struct.Q1HashEntry, %struct.Q1HashEntry* %129, i64 0, i32 6
  %508 = bitcast %struct.AVX2DoubleSumBuffer** %507 to %struct.AVX2DoubleSumBuffer.0**
  %509 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %508, align 8, !tbaa !33
  tail call void @avx2_double_sum_add(%struct.AVX2DoubleSumBuffer.0* noundef %509, double noundef %495) #11
  %510 = getelementptr inbounds %struct.Q1HashEntry, %struct.Q1HashEntry* %129, i64 0, i32 7
  %511 = bitcast %struct.AVX2DoubleSumBuffer** %510 to %struct.AVX2DoubleSumBuffer.0**
  %512 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %511, align 8, !tbaa !34
  tail call void @avx2_double_sum_add(%struct.AVX2DoubleSumBuffer.0* noundef %512, double noundef %497) #11
  %513 = getelementptr inbounds %struct.Q1HashEntry, %struct.Q1HashEntry* %129, i64 0, i32 8
  %514 = bitcast %struct.AVX2DoubleSumBuffer** %513 to %struct.AVX2DoubleSumBuffer.0**
  %515 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %514, align 8, !tbaa !35
  tail call void @avx2_double_sum_add(%struct.AVX2DoubleSumBuffer.0* noundef %515, double noundef %402) #11
  %516 = add nuw nsw i64 %18, 1
  %517 = icmp eq i64 %516, %16
  br i1 %517, label %518, label %17, !llvm.loop !36

518:                                              ; preds = %492, %4
  ret void
}

declare void @avx2_double_sum_add(%struct.AVX2DoubleSumBuffer.0* noundef, double noundef) local_unnamed_addr #5

; Function Attrs: nounwind uwtable
define dso_local void @q1_agg_finalize(%struct.Q1AggregationState* noundef %0) local_unnamed_addr #4 {
  %2 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 1
  %3 = load i8, i8* %2, align 8, !tbaa !5, !range !12
  %4 = icmp eq i8 %3, 0
  br i1 %4, label %5, label %83

5:                                                ; preds = %1
  %6 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 1
  %7 = load i32, i32* %6, align 8, !tbaa !22
  %8 = icmp sgt i32 %7, 0
  br i1 %8, label %17, label %9

9:                                                ; preds = %17, %5
  %10 = phi i32 [ %7, %5 ], [ %50, %17 ]
  %11 = sext i32 %10 to i64
  %12 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 0, i32 0
  tail call void @pdqsort(i8* noundef %12, i64 noundef %11, i64 noundef 104, i32 (i8*, i8*)* noundef nonnull @compare_hash_entry) #11
  %13 = tail call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([29 x i8], [29 x i8]* @str, i64 0, i64 0))
  %14 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([54 x i8], [54 x i8]* @.str.1, i64 0, i64 0), i8* noundef getelementptr inbounds ([13 x i8], [13 x i8]* @.str.2, i64 0, i64 0), i8* noundef getelementptr inbounds ([13 x i8], [13 x i8]* @.str.3, i64 0, i64 0), i8* noundef getelementptr inbounds ([6 x i8], [6 x i8]* @.str.4, i64 0, i64 0), i8* noundef getelementptr inbounds ([8 x i8], [8 x i8]* @.str.5, i64 0, i64 0), i8* noundef getelementptr inbounds ([10 x i8], [10 x i8]* @.str.6, i64 0, i64 0), i8* noundef getelementptr inbounds ([15 x i8], [15 x i8]* @.str.7, i64 0, i64 0), i8* noundef getelementptr inbounds ([11 x i8], [11 x i8]* @.str.8, i64 0, i64 0), i8* noundef getelementptr inbounds ([8 x i8], [8 x i8]* @.str.9, i64 0, i64 0), i8* noundef getelementptr inbounds ([9 x i8], [9 x i8]* @.str.10, i64 0, i64 0))
  %15 = load i32, i32* %6, align 8, !tbaa !22
  %16 = icmp sgt i32 %15, 0
  br i1 %16, label %55, label %53

17:                                               ; preds = %5, %17
  %18 = phi i64 [ %49, %17 ], [ 0, %5 ]
  %19 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %18, i32 4
  %20 = bitcast %struct.AVX2DoubleSumBuffer** %19 to %struct.AVX2DoubleSumBuffer.0**
  %21 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %20, align 8, !tbaa !31
  %22 = tail call double @avx2_double_sum_get_result(%struct.AVX2DoubleSumBuffer.0* noundef %21) #11
  %23 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %18, i32 9
  store double %22, double* %23, align 8, !tbaa !37
  %24 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %20, align 8, !tbaa !31
  tail call void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef %24) #11
  store %struct.AVX2DoubleSumBuffer* null, %struct.AVX2DoubleSumBuffer** %19, align 8, !tbaa !31
  %25 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %18, i32 5
  %26 = bitcast %struct.AVX2DoubleSumBuffer** %25 to %struct.AVX2DoubleSumBuffer.0**
  %27 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %26, align 8, !tbaa !32
  %28 = tail call double @avx2_double_sum_get_result(%struct.AVX2DoubleSumBuffer.0* noundef %27) #11
  %29 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %18, i32 10
  store double %28, double* %29, align 8, !tbaa !38
  %30 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %26, align 8, !tbaa !32
  tail call void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef %30) #11
  store %struct.AVX2DoubleSumBuffer* null, %struct.AVX2DoubleSumBuffer** %25, align 8, !tbaa !32
  %31 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %18, i32 6
  %32 = bitcast %struct.AVX2DoubleSumBuffer** %31 to %struct.AVX2DoubleSumBuffer.0**
  %33 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %32, align 8, !tbaa !33
  %34 = tail call double @avx2_double_sum_get_result(%struct.AVX2DoubleSumBuffer.0* noundef %33) #11
  %35 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %18, i32 11
  store double %34, double* %35, align 8, !tbaa !39
  %36 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %32, align 8, !tbaa !33
  tail call void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef %36) #11
  store %struct.AVX2DoubleSumBuffer* null, %struct.AVX2DoubleSumBuffer** %31, align 8, !tbaa !33
  %37 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %18, i32 7
  %38 = bitcast %struct.AVX2DoubleSumBuffer** %37 to %struct.AVX2DoubleSumBuffer.0**
  %39 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %38, align 8, !tbaa !34
  %40 = tail call double @avx2_double_sum_get_result(%struct.AVX2DoubleSumBuffer.0* noundef %39) #11
  %41 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %18, i32 12
  store double %40, double* %41, align 8, !tbaa !40
  %42 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %38, align 8, !tbaa !34
  tail call void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef %42) #11
  store %struct.AVX2DoubleSumBuffer* null, %struct.AVX2DoubleSumBuffer** %37, align 8, !tbaa !34
  %43 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %18, i32 8
  %44 = bitcast %struct.AVX2DoubleSumBuffer** %43 to %struct.AVX2DoubleSumBuffer.0**
  %45 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %44, align 8, !tbaa !35
  %46 = tail call double @avx2_double_sum_get_result(%struct.AVX2DoubleSumBuffer.0* noundef %45) #11
  %47 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %18, i32 13
  store double %46, double* %47, align 8, !tbaa !41
  %48 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %44, align 8, !tbaa !35
  tail call void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef %48) #11
  store %struct.AVX2DoubleSumBuffer* null, %struct.AVX2DoubleSumBuffer** %43, align 8, !tbaa !35
  %49 = add nuw nsw i64 %18, 1
  %50 = load i32, i32* %6, align 8, !tbaa !22
  %51 = sext i32 %50 to i64
  %52 = icmp slt i64 %49, %51
  br i1 %52, label %17, label %9, !llvm.loop !42

53:                                               ; preds = %55, %9
  %54 = tail call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([28 x i8], [28 x i8]* @str.13, i64 0, i64 0))
  store i8 1, i8* %2, align 8, !tbaa !5
  br label %83

55:                                               ; preds = %9, %55
  %56 = phi i64 [ %79, %55 ], [ 0, %9 ]
  %57 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %56, i32 9
  %58 = load double, double* %57, align 8, !tbaa !37
  %59 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %56, i32 3
  %60 = load i64, i64* %59, align 8, !tbaa !30
  %61 = sitofp i64 %60 to double
  %62 = fdiv double %58, %61
  %63 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %56, i32 13
  %64 = load double, double* %63, align 8, !tbaa !41
  %65 = fdiv double %64, %61
  %66 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %56, i32 0
  %67 = load i8, i8* %66, align 8, !tbaa !28
  %68 = sext i8 %67 to i32
  %69 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %56, i32 1
  %70 = load i8, i8* %69, align 1, !tbaa !29
  %71 = sext i8 %70 to i32
  %72 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %56, i32 10
  %73 = load double, double* %72, align 8, !tbaa !38
  %74 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %56, i32 11
  %75 = load double, double* %74, align 8, !tbaa !39
  %76 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %56, i32 12
  %77 = load double, double* %76, align 8, !tbaa !40
  %78 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([68 x i8], [68 x i8]* @.str.11, i64 0, i64 0), i32 noundef %68, i32 noundef %71, i64 noundef %60, double noundef %58, double noundef %73, double noundef %75, double noundef %77, double noundef %62, double noundef %65)
  %79 = add nuw nsw i64 %56, 1
  %80 = load i32, i32* %6, align 8, !tbaa !22
  %81 = sext i32 %80 to i64
  %82 = icmp slt i64 %79, %81
  br i1 %82, label %55, label %53, !llvm.loop !43

83:                                               ; preds = %1, %53
  ret void
}

declare void @pdqsort(i8* noundef, i64 noundef, i64 noundef, i32 (i8*, i8*)* noundef) local_unnamed_addr #5

; Function Attrs: mustprogress nofree norecurse nosync nounwind readonly uwtable willreturn
define internal i32 @compare_hash_entry(i8* nocapture noundef readonly %0, i8* nocapture noundef readonly %1) #6 {
  %3 = load i8, i8* %0, align 8, !tbaa !28
  %4 = load i8, i8* %1, align 8, !tbaa !28
  %5 = icmp slt i8 %3, %4
  br i1 %5, label %17, label %6

6:                                                ; preds = %2
  %7 = icmp sgt i8 %3, %4
  br i1 %7, label %17, label %8

8:                                                ; preds = %6
  %9 = getelementptr inbounds i8, i8* %0, i64 1
  %10 = load i8, i8* %9, align 1, !tbaa !29
  %11 = getelementptr inbounds i8, i8* %1, i64 1
  %12 = load i8, i8* %11, align 1, !tbaa !29
  %13 = icmp slt i8 %10, %12
  br i1 %13, label %17, label %14

14:                                               ; preds = %8
  %15 = icmp sgt i8 %10, %12
  %16 = zext i1 %15 to i32
  br label %17

17:                                               ; preds = %14, %8, %6, %2
  %18 = phi i32 [ -1, %2 ], [ 1, %6 ], [ -1, %8 ], [ %16, %14 ]
  ret i32 %18
}

; Function Attrs: nofree nounwind
declare noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #7

; Function Attrs: nounwind uwtable
define dso_local void @q1_agg_destroy(%struct.Q1AggregationState* noundef %0) local_unnamed_addr #4 {
  %2 = icmp eq %struct.Q1AggregationState* %0, null
  br i1 %2, label %49, label %3

3:                                                ; preds = %1
  %4 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 1
  %5 = load i8, i8* %4, align 8, !tbaa !5, !range !12
  %6 = icmp eq i8 %5, 0
  br i1 %6, label %7, label %47

7:                                                ; preds = %3
  %8 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 1
  %9 = load i32, i32* %8, align 8, !tbaa !22
  %10 = icmp sgt i32 %9, 0
  br i1 %10, label %11, label %47

11:                                               ; preds = %7, %42
  %12 = phi i64 [ %43, %42 ], [ 0, %7 ]
  %13 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %12, i32 4
  %14 = load %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer** %13, align 8, !tbaa !31
  %15 = icmp eq %struct.AVX2DoubleSumBuffer* %14, null
  br i1 %15, label %18, label %16

16:                                               ; preds = %11
  %17 = bitcast %struct.AVX2DoubleSumBuffer* %14 to %struct.AVX2DoubleSumBuffer.0*
  tail call void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef nonnull %17) #11
  br label %18

18:                                               ; preds = %16, %11
  %19 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %12, i32 5
  %20 = load %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer** %19, align 8, !tbaa !32
  %21 = icmp eq %struct.AVX2DoubleSumBuffer* %20, null
  br i1 %21, label %24, label %22

22:                                               ; preds = %18
  %23 = bitcast %struct.AVX2DoubleSumBuffer* %20 to %struct.AVX2DoubleSumBuffer.0*
  tail call void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef nonnull %23) #11
  br label %24

24:                                               ; preds = %22, %18
  %25 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %12, i32 6
  %26 = load %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer** %25, align 8, !tbaa !33
  %27 = icmp eq %struct.AVX2DoubleSumBuffer* %26, null
  br i1 %27, label %30, label %28

28:                                               ; preds = %24
  %29 = bitcast %struct.AVX2DoubleSumBuffer* %26 to %struct.AVX2DoubleSumBuffer.0*
  tail call void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef nonnull %29) #11
  br label %30

30:                                               ; preds = %28, %24
  %31 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %12, i32 7
  %32 = load %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer** %31, align 8, !tbaa !34
  %33 = icmp eq %struct.AVX2DoubleSumBuffer* %32, null
  br i1 %33, label %36, label %34

34:                                               ; preds = %30
  %35 = bitcast %struct.AVX2DoubleSumBuffer* %32 to %struct.AVX2DoubleSumBuffer.0*
  tail call void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef nonnull %35) #11
  br label %36

36:                                               ; preds = %34, %30
  %37 = getelementptr inbounds %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 %12, i32 8
  %38 = load %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer** %37, align 8, !tbaa !35
  %39 = icmp eq %struct.AVX2DoubleSumBuffer* %38, null
  br i1 %39, label %42, label %40

40:                                               ; preds = %36
  %41 = bitcast %struct.AVX2DoubleSumBuffer* %38 to %struct.AVX2DoubleSumBuffer.0*
  tail call void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef nonnull %41) #11
  br label %42

42:                                               ; preds = %40, %36
  %43 = add nuw nsw i64 %12, 1
  %44 = load i32, i32* %8, align 8, !tbaa !22
  %45 = sext i32 %44 to i64
  %46 = icmp slt i64 %43, %45
  br i1 %46, label %11, label %47, !llvm.loop !44

47:                                               ; preds = %42, %7, %3
  %48 = getelementptr %struct.Q1AggregationState, %struct.Q1AggregationState* %0, i64 0, i32 0, i32 0, i64 0, i32 0
  tail call void @free(i8* noundef %48) #11
  br label %49

49:                                               ; preds = %47, %1
  ret void
}

declare void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef) local_unnamed_addr #5

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn
declare void @free(i8* nocapture noundef) local_unnamed_addr #8

; Function Attrs: mustprogress nofree nounwind readonly willreturn
declare i64 @XXH3_64bits(i8* nocapture noundef, i64 noundef) local_unnamed_addr #9

declare %struct.AVX2DoubleSumBuffer.0* @avx2_double_sum_create(i32 noundef) local_unnamed_addr #5

declare double @avx2_double_sum_get_result(%struct.AVX2DoubleSumBuffer.0* noundef) local_unnamed_addr #5

; Function Attrs: nofree nounwind
declare noundef i32 @puts(i8* nocapture noundef readonly) local_unnamed_addr #10

attributes #0 = { mustprogress nofree nounwind uwtable willreturn "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { inaccessiblememonly mustprogress nofree nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { argmemonly mustprogress nofree nounwind willreturn writeonly }
attributes #4 = { nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { mustprogress nofree norecurse nosync nounwind readonly uwtable willreturn "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { inaccessiblemem_or_argmemonly mustprogress nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { mustprogress nofree nounwind readonly willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #10 = { nofree nounwind }
attributes #11 = { nounwind }
attributes #12 = { nounwind readonly willreturn }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
!5 = !{!6, !11, i64 106504}
!6 = !{!"", !7, i64 0, !11, i64 106504}
!7 = !{!"", !8, i64 0, !10, i64 106496}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = !{!"int", !8, i64 0}
!11 = !{!"_Bool", !8, i64 0}
!12 = !{i8 0, i8 2}
!13 = !{!10, !10, i64 0}
!14 = !{!15, !17, i64 48}
!15 = !{!"ArrowArray", !16, i64 0, !16, i64 8, !16, i64 16, !16, i64 24, !16, i64 32, !17, i64 40, !17, i64 48, !17, i64 56, !17, i64 64, !17, i64 72}
!16 = !{!"long", !8, i64 0}
!17 = !{!"any pointer", !8, i64 0}
!18 = !{!17, !17, i64 0}
!19 = !{!15, !17, i64 40}
!20 = !{!15, !16, i64 0}
!21 = !{!8, !8, i64 0}
!22 = !{!6, !10, i64 106496}
!23 = !{!24, !16, i64 8}
!24 = !{!"", !8, i64 0, !8, i64 1, !16, i64 8, !16, i64 16, !17, i64 24, !17, i64 32, !17, i64 40, !17, i64 48, !17, i64 56, !25, i64 64, !25, i64 72, !25, i64 80, !25, i64 88, !25, i64 96}
!25 = !{!"double", !8, i64 0}
!26 = distinct !{!26, !27}
!27 = !{!"llvm.loop.mustprogress"}
!28 = !{!24, !8, i64 0}
!29 = !{!24, !8, i64 1}
!30 = !{!24, !16, i64 16}
!31 = !{!24, !17, i64 24}
!32 = !{!24, !17, i64 32}
!33 = !{!24, !17, i64 40}
!34 = !{!24, !17, i64 48}
!35 = !{!24, !17, i64 56}
!36 = distinct !{!36, !27}
!37 = !{!24, !25, i64 64}
!38 = !{!24, !25, i64 72}
!39 = !{!24, !25, i64 80}
!40 = !{!24, !25, i64 88}
!41 = !{!24, !25, i64 96}
!42 = distinct !{!42, !27}
!43 = distinct !{!43, !27}
!44 = distinct !{!44, !27}
