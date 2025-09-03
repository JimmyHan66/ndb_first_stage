; ModuleID = 'q1_incremental_optimized.c'
source_filename = "q1_incremental_optimized.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.Q1AggregationState = type { %struct.Q1HashTable, i8 }
%struct.Q1HashTable = type { [1024 x %struct.Q1HashEntry], i32 }
%struct.Q1HashEntry = type { i8, i8, i64, i64, ptr, ptr, ptr, ptr, ptr, double, double, double, double, double }
%struct.ArrowArray = type { i64, i64, i64, i64, i64, ptr, ptr, ptr, ptr, ptr }

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
@str = private unnamed_addr constant [42 x i8] c"\0A=== Q1 Optimized Aggregation Results ===\00", align 1
@str.13 = private unnamed_addr constant [43 x i8] c"==========================================\00", align 1

; Function Attrs: mustprogress nofree nounwind willreturn memory(write, argmem: none, inaccessiblemem: readwrite) uwtable
define dso_local noalias noundef ptr @q1_agg_init_optimized() local_unnamed_addr #0 {
  %1 = tail call noalias dereferenceable_or_null(106512) ptr @malloc(i64 noundef 106512) #11
  %2 = icmp eq ptr %1, null
  br i1 %2, label %4, label %3

3:                                                ; preds = %0
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(106505) %1, i8 0, i64 106505, i1 false)
  br label %4

4:                                                ; preds = %3, %0
  ret ptr %1
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #2

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nounwind uwtable
define dso_local void @q1_agg_process_batch_optimized(ptr nocapture noundef %0, ptr nocapture noundef readonly %1, ptr nocapture noundef readonly %2, i32 noundef %3) local_unnamed_addr #4 {
  %5 = alloca [2 x i8], align 1
  %6 = getelementptr inbounds %struct.Q1AggregationState, ptr %0, i64 0, i32 1
  %7 = load i8, ptr %6, align 8, !tbaa !5, !range !12, !noundef !13
  %8 = icmp eq i8 %7, 0
  %9 = icmp sgt i32 %3, 0
  %10 = and i1 %8, %9
  br i1 %10, label %11, label %497

11:                                               ; preds = %4
  %12 = getelementptr inbounds %struct.ArrowArray, ptr %1, i64 0, i32 6
  %13 = getelementptr inbounds i8, ptr %5, i64 1
  %14 = getelementptr inbounds %struct.Q1HashTable, ptr %0, i64 0, i32 1
  %15 = zext nneg i32 %3 to i64
  br label %16

16:                                               ; preds = %11, %476
  %17 = phi i64 [ 0, %11 ], [ %495, %476 ]
  %18 = getelementptr inbounds i32, ptr %2, i64 %17
  %19 = load i32, ptr %18, align 4, !tbaa !14
  %20 = sext i32 %19 to i64
  %21 = load ptr, ptr %12, align 8, !tbaa !15
  %22 = getelementptr inbounds ptr, ptr %21, i64 4
  %23 = load ptr, ptr %22, align 8, !tbaa !19
  %24 = icmp eq ptr %23, null
  br i1 %24, label %48, label %25

25:                                               ; preds = %16
  %26 = getelementptr inbounds %struct.ArrowArray, ptr %23, i64 0, i32 5
  %27 = load ptr, ptr %26, align 8, !tbaa !20
  %28 = getelementptr inbounds ptr, ptr %27, i64 1
  %29 = load ptr, ptr %28, align 8, !tbaa !19
  %30 = icmp eq ptr %29, null
  br i1 %30, label %48, label %31

31:                                               ; preds = %25
  %32 = getelementptr inbounds ptr, ptr %27, i64 2
  %33 = load ptr, ptr %32, align 8, !tbaa !19
  %34 = icmp eq ptr %33, null
  br i1 %34, label %48, label %35

35:                                               ; preds = %31
  %36 = load i64, ptr %23, align 8, !tbaa !21
  %37 = icmp sgt i64 %36, %20
  br i1 %37, label %38, label %48

38:                                               ; preds = %35
  %39 = getelementptr inbounds i32, ptr %29, i64 %20
  %40 = load i32, ptr %39, align 4, !tbaa !14
  %41 = getelementptr i32, ptr %39, i64 1
  %42 = load i32, ptr %41, align 4, !tbaa !14
  %43 = icmp sgt i32 %42, %40
  br i1 %43, label %44, label %48

44:                                               ; preds = %38
  %45 = sext i32 %40 to i64
  %46 = getelementptr inbounds i8, ptr %33, i64 %45
  %47 = load i8, ptr %46, align 1, !tbaa !22
  br label %48

48:                                               ; preds = %16, %25, %31, %35, %38, %44
  %49 = phi i8 [ 63, %31 ], [ 63, %25 ], [ 63, %16 ], [ 63, %35 ], [ %47, %44 ], [ 63, %38 ]
  %50 = getelementptr inbounds ptr, ptr %21, i64 5
  %51 = load ptr, ptr %50, align 8, !tbaa !19
  %52 = icmp eq ptr %51, null
  br i1 %52, label %76, label %53

53:                                               ; preds = %48
  %54 = getelementptr inbounds %struct.ArrowArray, ptr %51, i64 0, i32 5
  %55 = load ptr, ptr %54, align 8, !tbaa !20
  %56 = getelementptr inbounds ptr, ptr %55, i64 1
  %57 = load ptr, ptr %56, align 8, !tbaa !19
  %58 = icmp eq ptr %57, null
  br i1 %58, label %76, label %59

59:                                               ; preds = %53
  %60 = getelementptr inbounds ptr, ptr %55, i64 2
  %61 = load ptr, ptr %60, align 8, !tbaa !19
  %62 = icmp eq ptr %61, null
  br i1 %62, label %76, label %63

63:                                               ; preds = %59
  %64 = load i64, ptr %51, align 8, !tbaa !21
  %65 = icmp sgt i64 %64, %20
  br i1 %65, label %66, label %76

66:                                               ; preds = %63
  %67 = getelementptr inbounds i32, ptr %57, i64 %20
  %68 = load i32, ptr %67, align 4, !tbaa !14
  %69 = getelementptr i32, ptr %67, i64 1
  %70 = load i32, ptr %69, align 4, !tbaa !14
  %71 = icmp sgt i32 %70, %68
  br i1 %71, label %72, label %76

72:                                               ; preds = %66
  %73 = sext i32 %68 to i64
  %74 = getelementptr inbounds i8, ptr %61, i64 %73
  %75 = load i8, ptr %74, align 1, !tbaa !22
  br label %76

76:                                               ; preds = %48, %53, %59, %63, %66, %72
  %77 = phi i8 [ 63, %59 ], [ 63, %53 ], [ 63, %48 ], [ 63, %63 ], [ %75, %72 ], [ 63, %66 ]
  call void @llvm.lifetime.start.p0(i64 2, ptr nonnull %5) #12
  store i8 %49, ptr %5, align 1, !tbaa !22
  store i8 %77, ptr %13, align 1, !tbaa !22
  %78 = call i64 @XXH3_64bits(ptr nocapture noundef nonnull %5, i64 noundef 2) #13
  call void @llvm.lifetime.end.p0(i64 2, ptr nonnull %5) #12
  %79 = load i32, ptr %14, align 8, !tbaa !23
  %80 = icmp sgt i32 %79, 0
  br i1 %80, label %81, label %93

81:                                               ; preds = %76
  %82 = zext nneg i32 %79 to i64
  br label %86

83:                                               ; preds = %86
  %84 = add nuw nsw i64 %87, 1
  %85 = icmp eq i64 %84, %82
  br i1 %85, label %93, label %86, !llvm.loop !24

86:                                               ; preds = %81, %83
  %87 = phi i64 [ 0, %81 ], [ %84, %83 ]
  %88 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %87, i32 2
  %89 = load i64, ptr %88, align 8, !tbaa !26
  %90 = icmp eq i64 %89, %78
  br i1 %90, label %91, label %83

91:                                               ; preds = %86
  %92 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %87
  br label %112

93:                                               ; preds = %83, %76
  %94 = add nsw i32 %79, 1
  store i32 %94, ptr %14, align 8, !tbaa !23
  %95 = sext i32 %79 to i64
  %96 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %95
  store i8 %49, ptr %96, align 8, !tbaa !29
  %97 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %95, i32 1
  store i8 %77, ptr %97, align 1, !tbaa !30
  %98 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %95, i32 2
  store i64 %78, ptr %98, align 8, !tbaa !26
  %99 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %95, i32 3
  store i64 0, ptr %99, align 8, !tbaa !31
  %100 = tail call ptr @avx2_double_sum_create(i32 noundef 512) #12
  %101 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %95, i32 4
  store ptr %100, ptr %101, align 8, !tbaa !32
  %102 = tail call ptr @avx2_double_sum_create(i32 noundef 512) #12
  %103 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %95, i32 5
  store ptr %102, ptr %103, align 8, !tbaa !33
  %104 = tail call ptr @avx2_double_sum_create(i32 noundef 512) #12
  %105 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %95, i32 6
  store ptr %104, ptr %105, align 8, !tbaa !34
  %106 = tail call ptr @avx2_double_sum_create(i32 noundef 512) #12
  %107 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %95, i32 7
  store ptr %106, ptr %107, align 8, !tbaa !35
  %108 = tail call ptr @avx2_double_sum_create(i32 noundef 512) #12
  %109 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %95, i32 8
  store ptr %108, ptr %109, align 8, !tbaa !36
  %110 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %95, i32 9
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(40) %110, i8 0, i64 40, i1 false)
  %111 = load ptr, ptr %12, align 8, !tbaa !15
  br label %112

112:                                              ; preds = %91, %93
  %113 = phi ptr [ %21, %91 ], [ %111, %93 ]
  %114 = phi ptr [ %92, %91 ], [ %96, %93 ]
  %115 = load ptr, ptr %113, align 8, !tbaa !19
  %116 = getelementptr inbounds %struct.ArrowArray, ptr %115, i64 0, i32 5
  %117 = load ptr, ptr %116, align 8, !tbaa !20
  %118 = getelementptr inbounds ptr, ptr %117, i64 1
  %119 = load ptr, ptr %118, align 8, !tbaa !19
  %120 = icmp eq ptr %119, null
  br i1 %120, label %203, label %121

121:                                              ; preds = %112
  %122 = shl nsw i64 %20, 4
  %123 = getelementptr inbounds i8, ptr %119, i64 %122
  %124 = load i8, ptr %123, align 1, !tbaa !22
  %125 = zext i8 %124 to i128
  %126 = getelementptr inbounds i8, ptr %123, i64 1
  %127 = load i8, ptr %126, align 1, !tbaa !22
  %128 = zext i8 %127 to i128
  %129 = shl nuw nsw i128 %128, 8
  %130 = or disjoint i128 %129, %125
  %131 = getelementptr inbounds i8, ptr %123, i64 2
  %132 = load i8, ptr %131, align 1, !tbaa !22
  %133 = zext i8 %132 to i128
  %134 = shl nuw nsw i128 %133, 16
  %135 = or disjoint i128 %134, %130
  %136 = getelementptr inbounds i8, ptr %123, i64 3
  %137 = load i8, ptr %136, align 1, !tbaa !22
  %138 = zext i8 %137 to i128
  %139 = shl nuw nsw i128 %138, 24
  %140 = or disjoint i128 %139, %135
  %141 = getelementptr inbounds i8, ptr %123, i64 4
  %142 = load i8, ptr %141, align 1, !tbaa !22
  %143 = zext i8 %142 to i128
  %144 = shl nuw nsw i128 %143, 32
  %145 = or disjoint i128 %144, %140
  %146 = getelementptr inbounds i8, ptr %123, i64 5
  %147 = load i8, ptr %146, align 1, !tbaa !22
  %148 = zext i8 %147 to i128
  %149 = shl nuw nsw i128 %148, 40
  %150 = or i128 %149, %145
  %151 = getelementptr inbounds i8, ptr %123, i64 6
  %152 = load i8, ptr %151, align 1, !tbaa !22
  %153 = zext i8 %152 to i128
  %154 = shl nuw nsw i128 %153, 48
  %155 = or i128 %154, %150
  %156 = getelementptr inbounds i8, ptr %123, i64 7
  %157 = load i8, ptr %156, align 1, !tbaa !22
  %158 = zext i8 %157 to i128
  %159 = shl nuw nsw i128 %158, 56
  %160 = or i128 %159, %155
  %161 = getelementptr inbounds i8, ptr %123, i64 8
  %162 = load i8, ptr %161, align 1, !tbaa !22
  %163 = zext i8 %162 to i128
  %164 = shl nuw nsw i128 %163, 64
  %165 = or i128 %164, %160
  %166 = getelementptr inbounds i8, ptr %123, i64 9
  %167 = load i8, ptr %166, align 1, !tbaa !22
  %168 = zext i8 %167 to i128
  %169 = shl nuw nsw i128 %168, 72
  %170 = or i128 %169, %165
  %171 = getelementptr inbounds i8, ptr %123, i64 10
  %172 = load i8, ptr %171, align 1, !tbaa !22
  %173 = zext i8 %172 to i128
  %174 = shl nuw nsw i128 %173, 80
  %175 = or i128 %174, %170
  %176 = getelementptr inbounds i8, ptr %123, i64 11
  %177 = load i8, ptr %176, align 1, !tbaa !22
  %178 = zext i8 %177 to i128
  %179 = shl nuw nsw i128 %178, 88
  %180 = or i128 %179, %175
  %181 = getelementptr inbounds i8, ptr %123, i64 12
  %182 = load i8, ptr %181, align 1, !tbaa !22
  %183 = zext i8 %182 to i128
  %184 = shl nuw nsw i128 %183, 96
  %185 = or i128 %184, %180
  %186 = getelementptr inbounds i8, ptr %123, i64 13
  %187 = load i8, ptr %186, align 1, !tbaa !22
  %188 = zext i8 %187 to i128
  %189 = shl nuw nsw i128 %188, 104
  %190 = or i128 %189, %185
  %191 = getelementptr inbounds i8, ptr %123, i64 14
  %192 = load i8, ptr %191, align 1, !tbaa !22
  %193 = zext i8 %192 to i128
  %194 = shl nuw nsw i128 %193, 112
  %195 = or i128 %194, %190
  %196 = getelementptr inbounds i8, ptr %123, i64 15
  %197 = load i8, ptr %196, align 1, !tbaa !22
  %198 = zext i8 %197 to i128
  %199 = shl nuw i128 %198, 120
  %200 = or i128 %199, %195
  %201 = sitofp i128 %200 to double
  %202 = fmul double %201, 1.000000e-02
  br label %203

203:                                              ; preds = %121, %112
  %204 = phi double [ %202, %121 ], [ 0.000000e+00, %112 ]
  %205 = getelementptr inbounds ptr, ptr %113, i64 1
  %206 = load ptr, ptr %205, align 8, !tbaa !19
  %207 = getelementptr inbounds %struct.ArrowArray, ptr %206, i64 0, i32 5
  %208 = load ptr, ptr %207, align 8, !tbaa !20
  %209 = getelementptr inbounds ptr, ptr %208, i64 1
  %210 = load ptr, ptr %209, align 8, !tbaa !19
  %211 = icmp eq ptr %210, null
  br i1 %211, label %294, label %212

212:                                              ; preds = %203
  %213 = shl nsw i64 %20, 4
  %214 = getelementptr inbounds i8, ptr %210, i64 %213
  %215 = load i8, ptr %214, align 1, !tbaa !22
  %216 = zext i8 %215 to i128
  %217 = getelementptr inbounds i8, ptr %214, i64 1
  %218 = load i8, ptr %217, align 1, !tbaa !22
  %219 = zext i8 %218 to i128
  %220 = shl nuw nsw i128 %219, 8
  %221 = or disjoint i128 %220, %216
  %222 = getelementptr inbounds i8, ptr %214, i64 2
  %223 = load i8, ptr %222, align 1, !tbaa !22
  %224 = zext i8 %223 to i128
  %225 = shl nuw nsw i128 %224, 16
  %226 = or disjoint i128 %225, %221
  %227 = getelementptr inbounds i8, ptr %214, i64 3
  %228 = load i8, ptr %227, align 1, !tbaa !22
  %229 = zext i8 %228 to i128
  %230 = shl nuw nsw i128 %229, 24
  %231 = or disjoint i128 %230, %226
  %232 = getelementptr inbounds i8, ptr %214, i64 4
  %233 = load i8, ptr %232, align 1, !tbaa !22
  %234 = zext i8 %233 to i128
  %235 = shl nuw nsw i128 %234, 32
  %236 = or disjoint i128 %235, %231
  %237 = getelementptr inbounds i8, ptr %214, i64 5
  %238 = load i8, ptr %237, align 1, !tbaa !22
  %239 = zext i8 %238 to i128
  %240 = shl nuw nsw i128 %239, 40
  %241 = or i128 %240, %236
  %242 = getelementptr inbounds i8, ptr %214, i64 6
  %243 = load i8, ptr %242, align 1, !tbaa !22
  %244 = zext i8 %243 to i128
  %245 = shl nuw nsw i128 %244, 48
  %246 = or i128 %245, %241
  %247 = getelementptr inbounds i8, ptr %214, i64 7
  %248 = load i8, ptr %247, align 1, !tbaa !22
  %249 = zext i8 %248 to i128
  %250 = shl nuw nsw i128 %249, 56
  %251 = or i128 %250, %246
  %252 = getelementptr inbounds i8, ptr %214, i64 8
  %253 = load i8, ptr %252, align 1, !tbaa !22
  %254 = zext i8 %253 to i128
  %255 = shl nuw nsw i128 %254, 64
  %256 = or i128 %255, %251
  %257 = getelementptr inbounds i8, ptr %214, i64 9
  %258 = load i8, ptr %257, align 1, !tbaa !22
  %259 = zext i8 %258 to i128
  %260 = shl nuw nsw i128 %259, 72
  %261 = or i128 %260, %256
  %262 = getelementptr inbounds i8, ptr %214, i64 10
  %263 = load i8, ptr %262, align 1, !tbaa !22
  %264 = zext i8 %263 to i128
  %265 = shl nuw nsw i128 %264, 80
  %266 = or i128 %265, %261
  %267 = getelementptr inbounds i8, ptr %214, i64 11
  %268 = load i8, ptr %267, align 1, !tbaa !22
  %269 = zext i8 %268 to i128
  %270 = shl nuw nsw i128 %269, 88
  %271 = or i128 %270, %266
  %272 = getelementptr inbounds i8, ptr %214, i64 12
  %273 = load i8, ptr %272, align 1, !tbaa !22
  %274 = zext i8 %273 to i128
  %275 = shl nuw nsw i128 %274, 96
  %276 = or i128 %275, %271
  %277 = getelementptr inbounds i8, ptr %214, i64 13
  %278 = load i8, ptr %277, align 1, !tbaa !22
  %279 = zext i8 %278 to i128
  %280 = shl nuw nsw i128 %279, 104
  %281 = or i128 %280, %276
  %282 = getelementptr inbounds i8, ptr %214, i64 14
  %283 = load i8, ptr %282, align 1, !tbaa !22
  %284 = zext i8 %283 to i128
  %285 = shl nuw nsw i128 %284, 112
  %286 = or i128 %285, %281
  %287 = getelementptr inbounds i8, ptr %214, i64 15
  %288 = load i8, ptr %287, align 1, !tbaa !22
  %289 = zext i8 %288 to i128
  %290 = shl nuw i128 %289, 120
  %291 = or i128 %290, %286
  %292 = sitofp i128 %291 to double
  %293 = fmul double %292, 1.000000e-02
  br label %294

294:                                              ; preds = %212, %203
  %295 = phi double [ %293, %212 ], [ 0.000000e+00, %203 ]
  %296 = getelementptr inbounds ptr, ptr %113, i64 2
  %297 = load ptr, ptr %296, align 8, !tbaa !19
  %298 = getelementptr inbounds %struct.ArrowArray, ptr %297, i64 0, i32 5
  %299 = load ptr, ptr %298, align 8, !tbaa !20
  %300 = getelementptr inbounds ptr, ptr %299, i64 1
  %301 = load ptr, ptr %300, align 8, !tbaa !19
  %302 = icmp eq ptr %301, null
  br i1 %302, label %385, label %303

303:                                              ; preds = %294
  %304 = shl nsw i64 %20, 4
  %305 = getelementptr inbounds i8, ptr %301, i64 %304
  %306 = load i8, ptr %305, align 1, !tbaa !22
  %307 = zext i8 %306 to i128
  %308 = getelementptr inbounds i8, ptr %305, i64 1
  %309 = load i8, ptr %308, align 1, !tbaa !22
  %310 = zext i8 %309 to i128
  %311 = shl nuw nsw i128 %310, 8
  %312 = or disjoint i128 %311, %307
  %313 = getelementptr inbounds i8, ptr %305, i64 2
  %314 = load i8, ptr %313, align 1, !tbaa !22
  %315 = zext i8 %314 to i128
  %316 = shl nuw nsw i128 %315, 16
  %317 = or disjoint i128 %316, %312
  %318 = getelementptr inbounds i8, ptr %305, i64 3
  %319 = load i8, ptr %318, align 1, !tbaa !22
  %320 = zext i8 %319 to i128
  %321 = shl nuw nsw i128 %320, 24
  %322 = or disjoint i128 %321, %317
  %323 = getelementptr inbounds i8, ptr %305, i64 4
  %324 = load i8, ptr %323, align 1, !tbaa !22
  %325 = zext i8 %324 to i128
  %326 = shl nuw nsw i128 %325, 32
  %327 = or disjoint i128 %326, %322
  %328 = getelementptr inbounds i8, ptr %305, i64 5
  %329 = load i8, ptr %328, align 1, !tbaa !22
  %330 = zext i8 %329 to i128
  %331 = shl nuw nsw i128 %330, 40
  %332 = or i128 %331, %327
  %333 = getelementptr inbounds i8, ptr %305, i64 6
  %334 = load i8, ptr %333, align 1, !tbaa !22
  %335 = zext i8 %334 to i128
  %336 = shl nuw nsw i128 %335, 48
  %337 = or i128 %336, %332
  %338 = getelementptr inbounds i8, ptr %305, i64 7
  %339 = load i8, ptr %338, align 1, !tbaa !22
  %340 = zext i8 %339 to i128
  %341 = shl nuw nsw i128 %340, 56
  %342 = or i128 %341, %337
  %343 = getelementptr inbounds i8, ptr %305, i64 8
  %344 = load i8, ptr %343, align 1, !tbaa !22
  %345 = zext i8 %344 to i128
  %346 = shl nuw nsw i128 %345, 64
  %347 = or i128 %346, %342
  %348 = getelementptr inbounds i8, ptr %305, i64 9
  %349 = load i8, ptr %348, align 1, !tbaa !22
  %350 = zext i8 %349 to i128
  %351 = shl nuw nsw i128 %350, 72
  %352 = or i128 %351, %347
  %353 = getelementptr inbounds i8, ptr %305, i64 10
  %354 = load i8, ptr %353, align 1, !tbaa !22
  %355 = zext i8 %354 to i128
  %356 = shl nuw nsw i128 %355, 80
  %357 = or i128 %356, %352
  %358 = getelementptr inbounds i8, ptr %305, i64 11
  %359 = load i8, ptr %358, align 1, !tbaa !22
  %360 = zext i8 %359 to i128
  %361 = shl nuw nsw i128 %360, 88
  %362 = or i128 %361, %357
  %363 = getelementptr inbounds i8, ptr %305, i64 12
  %364 = load i8, ptr %363, align 1, !tbaa !22
  %365 = zext i8 %364 to i128
  %366 = shl nuw nsw i128 %365, 96
  %367 = or i128 %366, %362
  %368 = getelementptr inbounds i8, ptr %305, i64 13
  %369 = load i8, ptr %368, align 1, !tbaa !22
  %370 = zext i8 %369 to i128
  %371 = shl nuw nsw i128 %370, 104
  %372 = or i128 %371, %367
  %373 = getelementptr inbounds i8, ptr %305, i64 14
  %374 = load i8, ptr %373, align 1, !tbaa !22
  %375 = zext i8 %374 to i128
  %376 = shl nuw nsw i128 %375, 112
  %377 = or i128 %376, %372
  %378 = getelementptr inbounds i8, ptr %305, i64 15
  %379 = load i8, ptr %378, align 1, !tbaa !22
  %380 = zext i8 %379 to i128
  %381 = shl nuw i128 %380, 120
  %382 = or i128 %381, %377
  %383 = sitofp i128 %382 to double
  %384 = fmul double %383, 1.000000e-02
  br label %385

385:                                              ; preds = %303, %294
  %386 = phi double [ %384, %303 ], [ 0.000000e+00, %294 ]
  %387 = getelementptr inbounds ptr, ptr %113, i64 3
  %388 = load ptr, ptr %387, align 8, !tbaa !19
  %389 = getelementptr inbounds %struct.ArrowArray, ptr %388, i64 0, i32 5
  %390 = load ptr, ptr %389, align 8, !tbaa !20
  %391 = getelementptr inbounds ptr, ptr %390, i64 1
  %392 = load ptr, ptr %391, align 8, !tbaa !19
  %393 = icmp eq ptr %392, null
  br i1 %393, label %476, label %394

394:                                              ; preds = %385
  %395 = shl nsw i64 %20, 4
  %396 = getelementptr inbounds i8, ptr %392, i64 %395
  %397 = load i8, ptr %396, align 1, !tbaa !22
  %398 = zext i8 %397 to i128
  %399 = getelementptr inbounds i8, ptr %396, i64 1
  %400 = load i8, ptr %399, align 1, !tbaa !22
  %401 = zext i8 %400 to i128
  %402 = shl nuw nsw i128 %401, 8
  %403 = or disjoint i128 %402, %398
  %404 = getelementptr inbounds i8, ptr %396, i64 2
  %405 = load i8, ptr %404, align 1, !tbaa !22
  %406 = zext i8 %405 to i128
  %407 = shl nuw nsw i128 %406, 16
  %408 = or disjoint i128 %407, %403
  %409 = getelementptr inbounds i8, ptr %396, i64 3
  %410 = load i8, ptr %409, align 1, !tbaa !22
  %411 = zext i8 %410 to i128
  %412 = shl nuw nsw i128 %411, 24
  %413 = or disjoint i128 %412, %408
  %414 = getelementptr inbounds i8, ptr %396, i64 4
  %415 = load i8, ptr %414, align 1, !tbaa !22
  %416 = zext i8 %415 to i128
  %417 = shl nuw nsw i128 %416, 32
  %418 = or disjoint i128 %417, %413
  %419 = getelementptr inbounds i8, ptr %396, i64 5
  %420 = load i8, ptr %419, align 1, !tbaa !22
  %421 = zext i8 %420 to i128
  %422 = shl nuw nsw i128 %421, 40
  %423 = or i128 %422, %418
  %424 = getelementptr inbounds i8, ptr %396, i64 6
  %425 = load i8, ptr %424, align 1, !tbaa !22
  %426 = zext i8 %425 to i128
  %427 = shl nuw nsw i128 %426, 48
  %428 = or i128 %427, %423
  %429 = getelementptr inbounds i8, ptr %396, i64 7
  %430 = load i8, ptr %429, align 1, !tbaa !22
  %431 = zext i8 %430 to i128
  %432 = shl nuw nsw i128 %431, 56
  %433 = or i128 %432, %428
  %434 = getelementptr inbounds i8, ptr %396, i64 8
  %435 = load i8, ptr %434, align 1, !tbaa !22
  %436 = zext i8 %435 to i128
  %437 = shl nuw nsw i128 %436, 64
  %438 = or i128 %437, %433
  %439 = getelementptr inbounds i8, ptr %396, i64 9
  %440 = load i8, ptr %439, align 1, !tbaa !22
  %441 = zext i8 %440 to i128
  %442 = shl nuw nsw i128 %441, 72
  %443 = or i128 %442, %438
  %444 = getelementptr inbounds i8, ptr %396, i64 10
  %445 = load i8, ptr %444, align 1, !tbaa !22
  %446 = zext i8 %445 to i128
  %447 = shl nuw nsw i128 %446, 80
  %448 = or i128 %447, %443
  %449 = getelementptr inbounds i8, ptr %396, i64 11
  %450 = load i8, ptr %449, align 1, !tbaa !22
  %451 = zext i8 %450 to i128
  %452 = shl nuw nsw i128 %451, 88
  %453 = or i128 %452, %448
  %454 = getelementptr inbounds i8, ptr %396, i64 12
  %455 = load i8, ptr %454, align 1, !tbaa !22
  %456 = zext i8 %455 to i128
  %457 = shl nuw nsw i128 %456, 96
  %458 = or i128 %457, %453
  %459 = getelementptr inbounds i8, ptr %396, i64 13
  %460 = load i8, ptr %459, align 1, !tbaa !22
  %461 = zext i8 %460 to i128
  %462 = shl nuw nsw i128 %461, 104
  %463 = or i128 %462, %458
  %464 = getelementptr inbounds i8, ptr %396, i64 14
  %465 = load i8, ptr %464, align 1, !tbaa !22
  %466 = zext i8 %465 to i128
  %467 = shl nuw nsw i128 %466, 112
  %468 = or i128 %467, %463
  %469 = getelementptr inbounds i8, ptr %396, i64 15
  %470 = load i8, ptr %469, align 1, !tbaa !22
  %471 = zext i8 %470 to i128
  %472 = shl nuw i128 %471, 120
  %473 = or i128 %472, %468
  %474 = sitofp i128 %473 to double
  %475 = fmul double %474, 1.000000e-02
  br label %476

476:                                              ; preds = %394, %385
  %477 = phi double [ %475, %394 ], [ 0.000000e+00, %385 ]
  %478 = fsub double 1.000000e+00, %386
  %479 = fmul double %295, %478
  %480 = fadd double %477, 1.000000e+00
  %481 = fmul double %479, %480
  %482 = getelementptr inbounds %struct.Q1HashEntry, ptr %114, i64 0, i32 3
  %483 = load i64, ptr %482, align 8, !tbaa !31
  %484 = add nsw i64 %483, 1
  store i64 %484, ptr %482, align 8, !tbaa !31
  %485 = getelementptr inbounds %struct.Q1HashEntry, ptr %114, i64 0, i32 4
  %486 = load ptr, ptr %485, align 8, !tbaa !32
  tail call void @avx2_double_sum_add(ptr noundef %486, double noundef %204) #12
  %487 = getelementptr inbounds %struct.Q1HashEntry, ptr %114, i64 0, i32 5
  %488 = load ptr, ptr %487, align 8, !tbaa !33
  tail call void @avx2_double_sum_add(ptr noundef %488, double noundef %295) #12
  %489 = getelementptr inbounds %struct.Q1HashEntry, ptr %114, i64 0, i32 6
  %490 = load ptr, ptr %489, align 8, !tbaa !34
  tail call void @avx2_double_sum_add(ptr noundef %490, double noundef %479) #12
  %491 = getelementptr inbounds %struct.Q1HashEntry, ptr %114, i64 0, i32 7
  %492 = load ptr, ptr %491, align 8, !tbaa !35
  tail call void @avx2_double_sum_add(ptr noundef %492, double noundef %481) #12
  %493 = getelementptr inbounds %struct.Q1HashEntry, ptr %114, i64 0, i32 8
  %494 = load ptr, ptr %493, align 8, !tbaa !36
  tail call void @avx2_double_sum_add(ptr noundef %494, double noundef %386) #12
  %495 = add nuw nsw i64 %17, 1
  %496 = icmp eq i64 %495, %15
  br i1 %496, label %497, label %16, !llvm.loop !37

497:                                              ; preds = %476, %4
  ret void
}

declare void @avx2_double_sum_add(ptr noundef, double noundef) local_unnamed_addr #5

; Function Attrs: nounwind uwtable
define dso_local void @q1_agg_finalize_optimized(ptr noundef %0) local_unnamed_addr #4 {
  %2 = getelementptr inbounds %struct.Q1AggregationState, ptr %0, i64 0, i32 1
  %3 = load i8, ptr %2, align 8, !tbaa !5, !range !12, !noundef !13
  %4 = icmp eq i8 %3, 0
  br i1 %4, label %5, label %78

5:                                                ; preds = %1
  %6 = getelementptr inbounds %struct.Q1HashTable, ptr %0, i64 0, i32 1
  %7 = load i32, ptr %6, align 8, !tbaa !23
  %8 = icmp sgt i32 %7, 0
  br i1 %8, label %17, label %9

9:                                                ; preds = %5
  %10 = sext i32 %7 to i64
  br label %11

11:                                               ; preds = %17, %9
  %12 = phi i64 [ %10, %9 ], [ %46, %17 ]
  tail call void @pdqsort(ptr noundef nonnull %0, i64 noundef %12, i64 noundef 104, ptr noundef nonnull @compare_hash_entry) #12
  %13 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str)
  %14 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, ptr noundef nonnull @.str.2, ptr noundef nonnull @.str.3, ptr noundef nonnull @.str.4, ptr noundef nonnull @.str.5, ptr noundef nonnull @.str.6, ptr noundef nonnull @.str.7, ptr noundef nonnull @.str.8, ptr noundef nonnull @.str.9, ptr noundef nonnull @.str.10)
  %15 = load i32, ptr %6, align 8, !tbaa !23
  %16 = icmp sgt i32 %15, 0
  br i1 %16, label %50, label %48

17:                                               ; preds = %5, %17
  %18 = phi i64 [ %44, %17 ], [ 0, %5 ]
  %19 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %18, i32 4
  %20 = load ptr, ptr %19, align 8, !tbaa !32
  %21 = tail call double @avx2_double_sum_get_result(ptr noundef %20) #12
  %22 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %18, i32 9
  store double %21, ptr %22, align 8, !tbaa !38
  %23 = load ptr, ptr %19, align 8, !tbaa !32
  tail call void @avx2_double_sum_destroy(ptr noundef %23) #12
  store ptr null, ptr %19, align 8, !tbaa !32
  %24 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %18, i32 5
  %25 = load ptr, ptr %24, align 8, !tbaa !33
  %26 = tail call double @avx2_double_sum_get_result(ptr noundef %25) #12
  %27 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %18, i32 10
  store double %26, ptr %27, align 8, !tbaa !39
  %28 = load ptr, ptr %24, align 8, !tbaa !33
  tail call void @avx2_double_sum_destroy(ptr noundef %28) #12
  store ptr null, ptr %24, align 8, !tbaa !33
  %29 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %18, i32 6
  %30 = load ptr, ptr %29, align 8, !tbaa !34
  %31 = tail call double @avx2_double_sum_get_result(ptr noundef %30) #12
  %32 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %18, i32 11
  store double %31, ptr %32, align 8, !tbaa !40
  %33 = load ptr, ptr %29, align 8, !tbaa !34
  tail call void @avx2_double_sum_destroy(ptr noundef %33) #12
  store ptr null, ptr %29, align 8, !tbaa !34
  %34 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %18, i32 7
  %35 = load ptr, ptr %34, align 8, !tbaa !35
  %36 = tail call double @avx2_double_sum_get_result(ptr noundef %35) #12
  %37 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %18, i32 12
  store double %36, ptr %37, align 8, !tbaa !41
  %38 = load ptr, ptr %34, align 8, !tbaa !35
  tail call void @avx2_double_sum_destroy(ptr noundef %38) #12
  store ptr null, ptr %34, align 8, !tbaa !35
  %39 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %18, i32 8
  %40 = load ptr, ptr %39, align 8, !tbaa !36
  %41 = tail call double @avx2_double_sum_get_result(ptr noundef %40) #12
  %42 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %18, i32 13
  store double %41, ptr %42, align 8, !tbaa !42
  %43 = load ptr, ptr %39, align 8, !tbaa !36
  tail call void @avx2_double_sum_destroy(ptr noundef %43) #12
  store ptr null, ptr %39, align 8, !tbaa !36
  %44 = add nuw nsw i64 %18, 1
  %45 = load i32, ptr %6, align 8, !tbaa !23
  %46 = sext i32 %45 to i64
  %47 = icmp slt i64 %44, %46
  br i1 %47, label %17, label %11, !llvm.loop !43

48:                                               ; preds = %50, %11
  %49 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.13)
  store i8 1, ptr %2, align 8, !tbaa !5
  br label %78

50:                                               ; preds = %11, %50
  %51 = phi i64 [ %74, %50 ], [ 0, %11 ]
  %52 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %51
  %53 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %51, i32 9
  %54 = load double, ptr %53, align 8, !tbaa !38
  %55 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %51, i32 3
  %56 = load i64, ptr %55, align 8, !tbaa !31
  %57 = sitofp i64 %56 to double
  %58 = fdiv double %54, %57
  %59 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %51, i32 13
  %60 = load double, ptr %59, align 8, !tbaa !42
  %61 = fdiv double %60, %57
  %62 = load i8, ptr %52, align 8, !tbaa !29
  %63 = sext i8 %62 to i32
  %64 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %51, i32 1
  %65 = load i8, ptr %64, align 1, !tbaa !30
  %66 = sext i8 %65 to i32
  %67 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %51, i32 10
  %68 = load double, ptr %67, align 8, !tbaa !39
  %69 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %51, i32 11
  %70 = load double, ptr %69, align 8, !tbaa !40
  %71 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %51, i32 12
  %72 = load double, ptr %71, align 8, !tbaa !41
  %73 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.11, i32 noundef %63, i32 noundef %66, i64 noundef %56, double noundef %54, double noundef %68, double noundef %70, double noundef %72, double noundef %58, double noundef %61)
  %74 = add nuw nsw i64 %51, 1
  %75 = load i32, ptr %6, align 8, !tbaa !23
  %76 = sext i32 %75 to i64
  %77 = icmp slt i64 %74, %76
  br i1 %77, label %50, label %48, !llvm.loop !44

78:                                               ; preds = %1, %48
  ret void
}

declare void @pdqsort(ptr noundef, i64 noundef, i64 noundef, ptr noundef) local_unnamed_addr #5

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable
define internal i32 @compare_hash_entry(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1) #6 {
  %3 = load i8, ptr %0, align 8, !tbaa !29
  %4 = load i8, ptr %1, align 8, !tbaa !29
  %5 = icmp slt i8 %3, %4
  br i1 %5, label %17, label %6

6:                                                ; preds = %2
  %7 = icmp sgt i8 %3, %4
  br i1 %7, label %17, label %8

8:                                                ; preds = %6
  %9 = getelementptr inbounds %struct.Q1HashEntry, ptr %0, i64 0, i32 1
  %10 = load i8, ptr %9, align 1, !tbaa !30
  %11 = getelementptr inbounds %struct.Q1HashEntry, ptr %1, i64 0, i32 1
  %12 = load i8, ptr %11, align 1, !tbaa !30
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
declare noundef i32 @printf(ptr nocapture noundef readonly, ...) local_unnamed_addr #7

; Function Attrs: nounwind uwtable
define dso_local void @q1_agg_destroy_optimized(ptr noundef %0) local_unnamed_addr #4 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %43, label %3

3:                                                ; preds = %1
  %4 = getelementptr inbounds %struct.Q1AggregationState, ptr %0, i64 0, i32 1
  %5 = load i8, ptr %4, align 8, !tbaa !5, !range !12, !noundef !13
  %6 = icmp eq i8 %5, 0
  br i1 %6, label %7, label %42

7:                                                ; preds = %3
  %8 = getelementptr inbounds %struct.Q1HashTable, ptr %0, i64 0, i32 1
  %9 = load i32, ptr %8, align 8, !tbaa !23
  %10 = icmp sgt i32 %9, 0
  br i1 %10, label %11, label %42

11:                                               ; preds = %7, %37
  %12 = phi i64 [ %38, %37 ], [ 0, %7 ]
  %13 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %12, i32 4
  %14 = load ptr, ptr %13, align 8, !tbaa !32
  %15 = icmp eq ptr %14, null
  br i1 %15, label %17, label %16

16:                                               ; preds = %11
  tail call void @avx2_double_sum_destroy(ptr noundef nonnull %14) #12
  br label %17

17:                                               ; preds = %16, %11
  %18 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %12, i32 5
  %19 = load ptr, ptr %18, align 8, !tbaa !33
  %20 = icmp eq ptr %19, null
  br i1 %20, label %22, label %21

21:                                               ; preds = %17
  tail call void @avx2_double_sum_destroy(ptr noundef nonnull %19) #12
  br label %22

22:                                               ; preds = %21, %17
  %23 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %12, i32 6
  %24 = load ptr, ptr %23, align 8, !tbaa !34
  %25 = icmp eq ptr %24, null
  br i1 %25, label %27, label %26

26:                                               ; preds = %22
  tail call void @avx2_double_sum_destroy(ptr noundef nonnull %24) #12
  br label %27

27:                                               ; preds = %26, %22
  %28 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %12, i32 7
  %29 = load ptr, ptr %28, align 8, !tbaa !35
  %30 = icmp eq ptr %29, null
  br i1 %30, label %32, label %31

31:                                               ; preds = %27
  tail call void @avx2_double_sum_destroy(ptr noundef nonnull %29) #12
  br label %32

32:                                               ; preds = %31, %27
  %33 = getelementptr inbounds [1024 x %struct.Q1HashEntry], ptr %0, i64 0, i64 %12, i32 8
  %34 = load ptr, ptr %33, align 8, !tbaa !36
  %35 = icmp eq ptr %34, null
  br i1 %35, label %37, label %36

36:                                               ; preds = %32
  tail call void @avx2_double_sum_destroy(ptr noundef nonnull %34) #12
  br label %37

37:                                               ; preds = %36, %32
  %38 = add nuw nsw i64 %12, 1
  %39 = load i32, ptr %8, align 8, !tbaa !23
  %40 = sext i32 %39 to i64
  %41 = icmp slt i64 %38, %40
  br i1 %41, label %11, label %42, !llvm.loop !45

42:                                               ; preds = %37, %7, %3
  tail call void @free(ptr noundef nonnull %0) #12
  br label %43

43:                                               ; preds = %42, %1
  ret void
}

declare void @avx2_double_sum_destroy(ptr noundef) local_unnamed_addr #5

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #8

; Function Attrs: mustprogress nofree nounwind willreturn memory(read)
declare i64 @XXH3_64bits(ptr nocapture noundef, i64 noundef) local_unnamed_addr #9

declare ptr @avx2_double_sum_create(i32 noundef) local_unnamed_addr #5

declare double @avx2_double_sum_get_result(ptr noundef) local_unnamed_addr #5

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr nocapture noundef readonly) local_unnamed_addr #10

attributes #0 = { mustprogress nofree nounwind willreturn memory(write, argmem: none, inaccessiblemem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #3 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #4 = { nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #5 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #6 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #7 = { nofree nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #8 = { mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #9 = { mustprogress nofree nounwind willreturn memory(read) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #10 = { nofree nounwind }
attributes #11 = { nounwind allocsize(0) }
attributes #12 = { nounwind }
attributes #13 = { nounwind willreturn memory(read) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Homebrew clang version 18.1.8"}
!5 = !{!6, !11, i64 106504}
!6 = !{!"", !7, i64 0, !11, i64 106504}
!7 = !{!"", !8, i64 0, !10, i64 106496}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = !{!"int", !8, i64 0}
!11 = !{!"_Bool", !8, i64 0}
!12 = !{i8 0, i8 2}
!13 = !{}
!14 = !{!10, !10, i64 0}
!15 = !{!16, !18, i64 48}
!16 = !{!"ArrowArray", !17, i64 0, !17, i64 8, !17, i64 16, !17, i64 24, !17, i64 32, !18, i64 40, !18, i64 48, !18, i64 56, !18, i64 64, !18, i64 72}
!17 = !{!"long", !8, i64 0}
!18 = !{!"any pointer", !8, i64 0}
!19 = !{!18, !18, i64 0}
!20 = !{!16, !18, i64 40}
!21 = !{!16, !17, i64 0}
!22 = !{!8, !8, i64 0}
!23 = !{!6, !10, i64 106496}
!24 = distinct !{!24, !25}
!25 = !{!"llvm.loop.mustprogress"}
!26 = !{!27, !17, i64 8}
!27 = !{!"", !8, i64 0, !8, i64 1, !17, i64 8, !17, i64 16, !18, i64 24, !18, i64 32, !18, i64 40, !18, i64 48, !18, i64 56, !28, i64 64, !28, i64 72, !28, i64 80, !28, i64 88, !28, i64 96}
!28 = !{!"double", !8, i64 0}
!29 = !{!27, !8, i64 0}
!30 = !{!27, !8, i64 1}
!31 = !{!27, !17, i64 16}
!32 = !{!27, !18, i64 24}
!33 = !{!27, !18, i64 32}
!34 = !{!27, !18, i64 40}
!35 = !{!27, !18, i64 48}
!36 = !{!27, !18, i64 56}
!37 = distinct !{!37, !25}
!38 = !{!27, !28, i64 64}
!39 = !{!27, !28, i64 72}
!40 = !{!27, !28, i64 80}
!41 = !{!27, !28, i64 88}
!42 = !{!27, !28, i64 96}
!43 = distinct !{!43, !25}
!44 = distinct !{!44, !25}
!45 = distinct !{!45, !25}
