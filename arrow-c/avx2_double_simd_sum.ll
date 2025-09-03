; ModuleID = 'avx2_double_simd_sum.c'
source_filename = "avx2_double_simd_sum.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.AVX2DoubleSumBuffer = type { double*, i32, i32 }

; Function Attrs: mustprogress nounwind uwtable willreturn
define dso_local noalias %struct.AVX2DoubleSumBuffer* @avx2_double_sum_create(i32 noundef %0) local_unnamed_addr #0 {
  %2 = icmp slt i32 %0, 1
  %3 = add nsw i32 %0, 3
  %4 = sdiv i32 %3, 4
  %5 = shl nsw i32 %4, 2
  %6 = select i1 %2, i32 8, i32 %5
  %7 = tail call noalias dereferenceable_or_null(16) i8* @malloc(i64 noundef 16) #8
  %8 = bitcast i8* %7 to %struct.AVX2DoubleSumBuffer*
  %9 = icmp eq i8* %7, null
  br i1 %9, label %20, label %10

10:                                               ; preds = %1
  %11 = sext i32 %6 to i64
  %12 = shl nsw i64 %11, 3
  %13 = tail call noalias align 32 i8* @aligned_alloc(i64 noundef 32, i64 noundef %12) #8
  %14 = bitcast i8* %7 to i8**
  store i8* %13, i8** %14, align 8, !tbaa !5
  %15 = icmp eq i8* %13, null
  br i1 %15, label %16, label %17

16:                                               ; preds = %10
  tail call void @free(i8* noundef nonnull %7) #8
  br label %20

17:                                               ; preds = %10
  %18 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %8, i64 0, i32 1
  store i32 %6, i32* %18, align 8, !tbaa !11
  %19 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %8, i64 0, i32 2
  store i32 0, i32* %19, align 4, !tbaa !12
  br label %20

20:                                               ; preds = %1, %17, %16
  %21 = phi %struct.AVX2DoubleSumBuffer* [ %8, %17 ], [ null, %16 ], [ null, %1 ]
  ret %struct.AVX2DoubleSumBuffer* %21
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn
declare noalias noundef i8* @malloc(i64 noundef) local_unnamed_addr #2

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn
declare noalias noundef i8* @aligned_alloc(i64 noundef, i64 noundef) local_unnamed_addr #2

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn
declare void @free(i8* nocapture noundef) local_unnamed_addr #3

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: mustprogress nounwind uwtable willreturn
define dso_local void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer* noundef %0) local_unnamed_addr #0 {
  %2 = icmp eq %struct.AVX2DoubleSumBuffer* %0, null
  br i1 %2, label %11, label %3

3:                                                ; preds = %1
  %4 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 0
  %5 = load double*, double** %4, align 8, !tbaa !5
  %6 = icmp eq double* %5, null
  br i1 %6, label %9, label %7

7:                                                ; preds = %3
  %8 = bitcast double* %5 to i8*
  tail call void @free(i8* noundef %8) #8
  br label %9

9:                                                ; preds = %7, %3
  %10 = bitcast %struct.AVX2DoubleSumBuffer* %0 to i8*
  tail call void @free(i8* noundef %10) #8
  br label %11

11:                                               ; preds = %9, %1
  ret void
}

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local void @avx2_double_sum_add(%struct.AVX2DoubleSumBuffer* noundef %0, double noundef %1) local_unnamed_addr #4 {
  %3 = icmp eq %struct.AVX2DoubleSumBuffer* %0, null
  br i1 %3, label %101, label %4

4:                                                ; preds = %2
  %5 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 2
  %6 = load i32, i32* %5, align 4, !tbaa !12
  %7 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 1
  %8 = load i32, i32* %7, align 8, !tbaa !11
  %9 = icmp sge i32 %6, %8
  %10 = icmp sgt i32 %6, 3
  %11 = and i1 %10, %9
  br i1 %11, label %12, label %94

12:                                               ; preds = %4
  %13 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 0
  %14 = load double*, double** %13, align 8, !tbaa !5
  %15 = icmp ugt i32 %6, 7
  %16 = and i32 %6, 3
  %17 = icmp eq i32 %16, 0
  %18 = and i1 %15, %17
  br i1 %18, label %19, label %94

19:                                               ; preds = %12
  %20 = bitcast double* %14 to <4 x double>*
  %21 = load <4 x double>, <4 x double>* %20, align 1, !tbaa !13
  %22 = zext i32 %6 to i64
  %23 = add nsw i64 %22, -5
  %24 = lshr i64 %23, 2
  %25 = add nuw nsw i64 %24, 1
  %26 = and i64 %25, 7
  %27 = icmp ult i64 %23, 28
  br i1 %27, label %30, label %28

28:                                               ; preds = %19
  %29 = and i64 %25, 9223372036854775800
  br label %48

30:                                               ; preds = %48, %19
  %31 = phi <4 x double> [ undef, %19 ], [ %90, %48 ]
  %32 = phi i64 [ 4, %19 ], [ %91, %48 ]
  %33 = phi <4 x double> [ %21, %19 ], [ %90, %48 ]
  %34 = icmp eq i64 %26, 0
  br i1 %34, label %46, label %35

35:                                               ; preds = %30, %35
  %36 = phi i64 [ %43, %35 ], [ %32, %30 ]
  %37 = phi <4 x double> [ %42, %35 ], [ %33, %30 ]
  %38 = phi i64 [ %44, %35 ], [ 0, %30 ]
  %39 = getelementptr inbounds double, double* %14, i64 %36
  %40 = bitcast double* %39 to <4 x double>*
  %41 = load <4 x double>, <4 x double>* %40, align 1, !tbaa !13
  %42 = fadd <4 x double> %37, %41
  %43 = add nuw nsw i64 %36, 4
  %44 = add i64 %38, 1
  %45 = icmp eq i64 %44, %26
  br i1 %45, label %46, label %35, !llvm.loop !14

46:                                               ; preds = %35, %30
  %47 = phi <4 x double> [ %31, %30 ], [ %42, %35 ]
  store <4 x double> %47, <4 x double>* %20, align 1, !tbaa !13
  br label %94

48:                                               ; preds = %48, %28
  %49 = phi i64 [ 4, %28 ], [ %91, %48 ]
  %50 = phi <4 x double> [ %21, %28 ], [ %90, %48 ]
  %51 = phi i64 [ 0, %28 ], [ %92, %48 ]
  %52 = getelementptr inbounds double, double* %14, i64 %49
  %53 = bitcast double* %52 to <4 x double>*
  %54 = load <4 x double>, <4 x double>* %53, align 1, !tbaa !13
  %55 = fadd <4 x double> %50, %54
  %56 = add nuw nsw i64 %49, 4
  %57 = getelementptr inbounds double, double* %14, i64 %56
  %58 = bitcast double* %57 to <4 x double>*
  %59 = load <4 x double>, <4 x double>* %58, align 1, !tbaa !13
  %60 = fadd <4 x double> %55, %59
  %61 = add nuw nsw i64 %49, 8
  %62 = getelementptr inbounds double, double* %14, i64 %61
  %63 = bitcast double* %62 to <4 x double>*
  %64 = load <4 x double>, <4 x double>* %63, align 1, !tbaa !13
  %65 = fadd <4 x double> %60, %64
  %66 = add nuw nsw i64 %49, 12
  %67 = getelementptr inbounds double, double* %14, i64 %66
  %68 = bitcast double* %67 to <4 x double>*
  %69 = load <4 x double>, <4 x double>* %68, align 1, !tbaa !13
  %70 = fadd <4 x double> %65, %69
  %71 = add nuw nsw i64 %49, 16
  %72 = getelementptr inbounds double, double* %14, i64 %71
  %73 = bitcast double* %72 to <4 x double>*
  %74 = load <4 x double>, <4 x double>* %73, align 1, !tbaa !13
  %75 = fadd <4 x double> %70, %74
  %76 = add nuw nsw i64 %49, 20
  %77 = getelementptr inbounds double, double* %14, i64 %76
  %78 = bitcast double* %77 to <4 x double>*
  %79 = load <4 x double>, <4 x double>* %78, align 1, !tbaa !13
  %80 = fadd <4 x double> %75, %79
  %81 = add nuw nsw i64 %49, 24
  %82 = getelementptr inbounds double, double* %14, i64 %81
  %83 = bitcast double* %82 to <4 x double>*
  %84 = load <4 x double>, <4 x double>* %83, align 1, !tbaa !13
  %85 = fadd <4 x double> %80, %84
  %86 = add nuw nsw i64 %49, 28
  %87 = getelementptr inbounds double, double* %14, i64 %86
  %88 = bitcast double* %87 to <4 x double>*
  %89 = load <4 x double>, <4 x double>* %88, align 1, !tbaa !13
  %90 = fadd <4 x double> %85, %89
  %91 = add nuw nsw i64 %49, 32
  %92 = add i64 %51, 8
  %93 = icmp eq i64 %92, %29
  br i1 %93, label %30, label %48, !llvm.loop !16

94:                                               ; preds = %46, %12, %4
  %95 = phi i32 [ %6, %4 ], [ 4, %12 ], [ 4, %46 ]
  %96 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 0
  %97 = load double*, double** %96, align 8, !tbaa !5
  %98 = sext i32 %95 to i64
  %99 = getelementptr inbounds double, double* %97, i64 %98
  store double %1, double* %99, align 8, !tbaa !18
  %100 = add nsw i32 %95, 1
  store i32 %100, i32* %5, align 4, !tbaa !12
  br label %101

101:                                              ; preds = %2, %94
  ret void
}

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local void @avx2_double_sum_add_batch(%struct.AVX2DoubleSumBuffer* noundef %0, double* noundef readonly %1, i32 noundef %2) local_unnamed_addr #4 {
  %4 = icmp eq %struct.AVX2DoubleSumBuffer* %0, null
  %5 = icmp eq double* %1, null
  %6 = or i1 %4, %5
  %7 = icmp slt i32 %2, 1
  %8 = or i1 %6, %7
  br i1 %8, label %113, label %9

9:                                                ; preds = %3
  %10 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 2
  %11 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 1
  %12 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 0
  %13 = zext i32 %2 to i64
  %14 = load i32, i32* %10, align 4, !tbaa !12
  br label %15

15:                                               ; preds = %9, %105
  %16 = phi i32 [ %14, %9 ], [ %110, %105 ]
  %17 = phi i64 [ 0, %9 ], [ %111, %105 ]
  %18 = getelementptr inbounds double, double* %1, i64 %17
  %19 = load double, double* %18, align 8, !tbaa !18
  %20 = load i32, i32* %11, align 8, !tbaa !11
  %21 = icmp sge i32 %16, %20
  %22 = icmp sgt i32 %16, 3
  %23 = and i1 %22, %21
  br i1 %23, label %24, label %105

24:                                               ; preds = %15
  %25 = load double*, double** %12, align 8, !tbaa !5
  %26 = icmp ugt i32 %16, 7
  %27 = and i32 %16, 3
  %28 = icmp eq i32 %27, 0
  %29 = and i1 %26, %28
  br i1 %29, label %30, label %105

30:                                               ; preds = %24
  %31 = bitcast double* %25 to <4 x double>*
  %32 = load <4 x double>, <4 x double>* %31, align 1, !tbaa !13
  %33 = zext i32 %16 to i64
  %34 = add nsw i64 %33, -5
  %35 = lshr i64 %34, 2
  %36 = add nuw nsw i64 %35, 1
  %37 = and i64 %36, 7
  %38 = icmp ult i64 %34, 28
  br i1 %38, label %41, label %39

39:                                               ; preds = %30
  %40 = and i64 %36, 9223372036854775800
  br label %59

41:                                               ; preds = %59, %30
  %42 = phi <4 x double> [ undef, %30 ], [ %101, %59 ]
  %43 = phi i64 [ 4, %30 ], [ %102, %59 ]
  %44 = phi <4 x double> [ %32, %30 ], [ %101, %59 ]
  %45 = icmp eq i64 %37, 0
  br i1 %45, label %57, label %46

46:                                               ; preds = %41, %46
  %47 = phi i64 [ %54, %46 ], [ %43, %41 ]
  %48 = phi <4 x double> [ %53, %46 ], [ %44, %41 ]
  %49 = phi i64 [ %55, %46 ], [ 0, %41 ]
  %50 = getelementptr inbounds double, double* %25, i64 %47
  %51 = bitcast double* %50 to <4 x double>*
  %52 = load <4 x double>, <4 x double>* %51, align 1, !tbaa !13
  %53 = fadd <4 x double> %48, %52
  %54 = add nuw nsw i64 %47, 4
  %55 = add i64 %49, 1
  %56 = icmp eq i64 %55, %37
  br i1 %56, label %57, label %46, !llvm.loop !20

57:                                               ; preds = %46, %41
  %58 = phi <4 x double> [ %42, %41 ], [ %53, %46 ]
  store <4 x double> %58, <4 x double>* %31, align 1, !tbaa !13
  br label %105

59:                                               ; preds = %59, %39
  %60 = phi i64 [ 4, %39 ], [ %102, %59 ]
  %61 = phi <4 x double> [ %32, %39 ], [ %101, %59 ]
  %62 = phi i64 [ 0, %39 ], [ %103, %59 ]
  %63 = getelementptr inbounds double, double* %25, i64 %60
  %64 = bitcast double* %63 to <4 x double>*
  %65 = load <4 x double>, <4 x double>* %64, align 1, !tbaa !13
  %66 = fadd <4 x double> %61, %65
  %67 = add nuw nsw i64 %60, 4
  %68 = getelementptr inbounds double, double* %25, i64 %67
  %69 = bitcast double* %68 to <4 x double>*
  %70 = load <4 x double>, <4 x double>* %69, align 1, !tbaa !13
  %71 = fadd <4 x double> %66, %70
  %72 = add nuw nsw i64 %60, 8
  %73 = getelementptr inbounds double, double* %25, i64 %72
  %74 = bitcast double* %73 to <4 x double>*
  %75 = load <4 x double>, <4 x double>* %74, align 1, !tbaa !13
  %76 = fadd <4 x double> %71, %75
  %77 = add nuw nsw i64 %60, 12
  %78 = getelementptr inbounds double, double* %25, i64 %77
  %79 = bitcast double* %78 to <4 x double>*
  %80 = load <4 x double>, <4 x double>* %79, align 1, !tbaa !13
  %81 = fadd <4 x double> %76, %80
  %82 = add nuw nsw i64 %60, 16
  %83 = getelementptr inbounds double, double* %25, i64 %82
  %84 = bitcast double* %83 to <4 x double>*
  %85 = load <4 x double>, <4 x double>* %84, align 1, !tbaa !13
  %86 = fadd <4 x double> %81, %85
  %87 = add nuw nsw i64 %60, 20
  %88 = getelementptr inbounds double, double* %25, i64 %87
  %89 = bitcast double* %88 to <4 x double>*
  %90 = load <4 x double>, <4 x double>* %89, align 1, !tbaa !13
  %91 = fadd <4 x double> %86, %90
  %92 = add nuw nsw i64 %60, 24
  %93 = getelementptr inbounds double, double* %25, i64 %92
  %94 = bitcast double* %93 to <4 x double>*
  %95 = load <4 x double>, <4 x double>* %94, align 1, !tbaa !13
  %96 = fadd <4 x double> %91, %95
  %97 = add nuw nsw i64 %60, 28
  %98 = getelementptr inbounds double, double* %25, i64 %97
  %99 = bitcast double* %98 to <4 x double>*
  %100 = load <4 x double>, <4 x double>* %99, align 1, !tbaa !13
  %101 = fadd <4 x double> %96, %100
  %102 = add nuw nsw i64 %60, 32
  %103 = add i64 %62, 8
  %104 = icmp eq i64 %103, %40
  br i1 %104, label %41, label %59, !llvm.loop !16

105:                                              ; preds = %57, %24, %15
  %106 = phi i32 [ %16, %15 ], [ 4, %24 ], [ 4, %57 ]
  %107 = load double*, double** %12, align 8, !tbaa !5
  %108 = sext i32 %106 to i64
  %109 = getelementptr inbounds double, double* %107, i64 %108
  store double %19, double* %109, align 8, !tbaa !18
  %110 = add nsw i32 %106, 1
  store i32 %110, i32* %10, align 4, !tbaa !12
  %111 = add nuw nsw i64 %17, 1
  %112 = icmp eq i64 %111, %13
  br i1 %112, label %113, label %15, !llvm.loop !21

113:                                              ; preds = %105, %3
  ret void
}

; Function Attrs: nofree nosync nounwind readonly uwtable
define dso_local double @avx2_double_sum_get_result(%struct.AVX2DoubleSumBuffer* noundef readonly %0) local_unnamed_addr #5 {
  %2 = alloca <4 x double>, align 16
  %3 = icmp eq %struct.AVX2DoubleSumBuffer* %0, null
  br i1 %3, label %212, label %4

4:                                                ; preds = %1
  %5 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 2
  %6 = load i32, i32* %5, align 4, !tbaa !12
  %7 = icmp eq i32 %6, 0
  br i1 %7, label %212, label %8

8:                                                ; preds = %4
  %9 = icmp slt i32 %6, 4
  br i1 %9, label %10, label %27

10:                                               ; preds = %8
  %11 = icmp sgt i32 %6, 0
  br i1 %11, label %12, label %212

12:                                               ; preds = %10
  %13 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 0
  %14 = load double*, double** %13, align 8, !tbaa !5
  %15 = load double, double* %14, align 8, !tbaa !18
  %16 = fadd double %15, 0.000000e+00
  %17 = icmp eq i32 %6, 1
  br i1 %17, label %212, label %18, !llvm.loop !22

18:                                               ; preds = %12
  %19 = getelementptr inbounds double, double* %14, i64 1
  %20 = load double, double* %19, align 8, !tbaa !18
  %21 = fadd double %16, %20
  %22 = icmp eq i32 %6, 2
  br i1 %22, label %212, label %23, !llvm.loop !22

23:                                               ; preds = %18
  %24 = getelementptr inbounds double, double* %14, i64 2
  %25 = load double, double* %24, align 8, !tbaa !18
  %26 = fadd double %21, %25
  br label %212

27:                                               ; preds = %8
  %28 = and i32 %6, 3
  %29 = icmp eq i32 %28, 0
  br i1 %29, label %30, label %116

30:                                               ; preds = %27
  %31 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 0
  %32 = load double*, double** %31, align 8, !tbaa !5
  %33 = bitcast double* %32 to <4 x double>*
  %34 = load <4 x double>, <4 x double>* %33, align 1, !tbaa !13
  %35 = icmp ugt i32 %6, 4
  br i1 %35, label %36, label %61

36:                                               ; preds = %30
  %37 = zext i32 %6 to i64
  %38 = add nsw i64 %37, -5
  %39 = lshr i64 %38, 2
  %40 = add nuw nsw i64 %39, 1
  %41 = and i64 %40, 7
  %42 = icmp ult i64 %38, 28
  br i1 %42, label %45, label %43

43:                                               ; preds = %36
  %44 = and i64 %40, 9223372036854775800
  br label %70

45:                                               ; preds = %70, %36
  %46 = phi <4 x double> [ undef, %36 ], [ %112, %70 ]
  %47 = phi i64 [ 4, %36 ], [ %113, %70 ]
  %48 = phi <4 x double> [ %34, %36 ], [ %112, %70 ]
  %49 = icmp eq i64 %41, 0
  br i1 %49, label %61, label %50

50:                                               ; preds = %45, %50
  %51 = phi i64 [ %58, %50 ], [ %47, %45 ]
  %52 = phi <4 x double> [ %57, %50 ], [ %48, %45 ]
  %53 = phi i64 [ %59, %50 ], [ 0, %45 ]
  %54 = getelementptr inbounds double, double* %32, i64 %51
  %55 = bitcast double* %54 to <4 x double>*
  %56 = load <4 x double>, <4 x double>* %55, align 1, !tbaa !13
  %57 = fadd <4 x double> %52, %56
  %58 = add nuw nsw i64 %51, 4
  %59 = add i64 %53, 1
  %60 = icmp eq i64 %59, %41
  br i1 %60, label %61, label %50, !llvm.loop !23

61:                                               ; preds = %45, %50, %30
  %62 = phi <4 x double> [ %34, %30 ], [ %46, %45 ], [ %57, %50 ]
  %63 = shufflevector <4 x double> %62, <4 x double> poison, <2 x i32> <i32 0, i32 1>
  %64 = shufflevector <4 x double> %62, <4 x double> poison, <2 x i32> <i32 2, i32 3>
  %65 = fadd <2 x double> %63, %64
  %66 = shufflevector <2 x double> %65, <2 x double> poison, <2 x i32> <i32 1, i32 undef>
  %67 = fadd <2 x double> %65, %66
  %68 = extractelement <2 x double> %67, i64 0
  %69 = fadd double %68, 0.000000e+00
  br label %212

70:                                               ; preds = %70, %43
  %71 = phi i64 [ 4, %43 ], [ %113, %70 ]
  %72 = phi <4 x double> [ %34, %43 ], [ %112, %70 ]
  %73 = phi i64 [ 0, %43 ], [ %114, %70 ]
  %74 = getelementptr inbounds double, double* %32, i64 %71
  %75 = bitcast double* %74 to <4 x double>*
  %76 = load <4 x double>, <4 x double>* %75, align 1, !tbaa !13
  %77 = fadd <4 x double> %72, %76
  %78 = add nuw nsw i64 %71, 4
  %79 = getelementptr inbounds double, double* %32, i64 %78
  %80 = bitcast double* %79 to <4 x double>*
  %81 = load <4 x double>, <4 x double>* %80, align 1, !tbaa !13
  %82 = fadd <4 x double> %77, %81
  %83 = add nuw nsw i64 %71, 8
  %84 = getelementptr inbounds double, double* %32, i64 %83
  %85 = bitcast double* %84 to <4 x double>*
  %86 = load <4 x double>, <4 x double>* %85, align 1, !tbaa !13
  %87 = fadd <4 x double> %82, %86
  %88 = add nuw nsw i64 %71, 12
  %89 = getelementptr inbounds double, double* %32, i64 %88
  %90 = bitcast double* %89 to <4 x double>*
  %91 = load <4 x double>, <4 x double>* %90, align 1, !tbaa !13
  %92 = fadd <4 x double> %87, %91
  %93 = add nuw nsw i64 %71, 16
  %94 = getelementptr inbounds double, double* %32, i64 %93
  %95 = bitcast double* %94 to <4 x double>*
  %96 = load <4 x double>, <4 x double>* %95, align 1, !tbaa !13
  %97 = fadd <4 x double> %92, %96
  %98 = add nuw nsw i64 %71, 20
  %99 = getelementptr inbounds double, double* %32, i64 %98
  %100 = bitcast double* %99 to <4 x double>*
  %101 = load <4 x double>, <4 x double>* %100, align 1, !tbaa !13
  %102 = fadd <4 x double> %97, %101
  %103 = add nuw nsw i64 %71, 24
  %104 = getelementptr inbounds double, double* %32, i64 %103
  %105 = bitcast double* %104 to <4 x double>*
  %106 = load <4 x double>, <4 x double>* %105, align 1, !tbaa !13
  %107 = fadd <4 x double> %102, %106
  %108 = add nuw nsw i64 %71, 28
  %109 = getelementptr inbounds double, double* %32, i64 %108
  %110 = bitcast double* %109 to <4 x double>*
  %111 = load <4 x double>, <4 x double>* %110, align 1, !tbaa !13
  %112 = fadd <4 x double> %107, %111
  %113 = add nuw nsw i64 %71, 32
  %114 = add i64 %73, 8
  %115 = icmp eq i64 %114, %44
  br i1 %115, label %45, label %70, !llvm.loop !24

116:                                              ; preds = %27
  %117 = and i32 %6, -4
  %118 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 0
  %119 = load double*, double** %118, align 8, !tbaa !5
  %120 = bitcast double* %119 to <4 x double>*
  %121 = load <4 x double>, <4 x double>* %120, align 1, !tbaa !13
  %122 = icmp ugt i32 %117, 4
  br i1 %122, label %123, label %194

123:                                              ; preds = %116
  %124 = zext i32 %117 to i64
  %125 = add nsw i64 %124, -5
  %126 = lshr i64 %125, 2
  %127 = add nuw nsw i64 %126, 1
  %128 = and i64 %127, 7
  %129 = icmp ult i64 %125, 28
  br i1 %129, label %178, label %130

130:                                              ; preds = %123
  %131 = and i64 %127, 9223372036854775800
  br label %132

132:                                              ; preds = %132, %130
  %133 = phi i64 [ 4, %130 ], [ %175, %132 ]
  %134 = phi <4 x double> [ %121, %130 ], [ %174, %132 ]
  %135 = phi i64 [ 0, %130 ], [ %176, %132 ]
  %136 = getelementptr inbounds double, double* %119, i64 %133
  %137 = bitcast double* %136 to <4 x double>*
  %138 = load <4 x double>, <4 x double>* %137, align 1, !tbaa !13
  %139 = fadd <4 x double> %134, %138
  %140 = add nuw nsw i64 %133, 4
  %141 = getelementptr inbounds double, double* %119, i64 %140
  %142 = bitcast double* %141 to <4 x double>*
  %143 = load <4 x double>, <4 x double>* %142, align 1, !tbaa !13
  %144 = fadd <4 x double> %139, %143
  %145 = add nuw nsw i64 %133, 8
  %146 = getelementptr inbounds double, double* %119, i64 %145
  %147 = bitcast double* %146 to <4 x double>*
  %148 = load <4 x double>, <4 x double>* %147, align 1, !tbaa !13
  %149 = fadd <4 x double> %144, %148
  %150 = add nuw nsw i64 %133, 12
  %151 = getelementptr inbounds double, double* %119, i64 %150
  %152 = bitcast double* %151 to <4 x double>*
  %153 = load <4 x double>, <4 x double>* %152, align 1, !tbaa !13
  %154 = fadd <4 x double> %149, %153
  %155 = add nuw nsw i64 %133, 16
  %156 = getelementptr inbounds double, double* %119, i64 %155
  %157 = bitcast double* %156 to <4 x double>*
  %158 = load <4 x double>, <4 x double>* %157, align 1, !tbaa !13
  %159 = fadd <4 x double> %154, %158
  %160 = add nuw nsw i64 %133, 20
  %161 = getelementptr inbounds double, double* %119, i64 %160
  %162 = bitcast double* %161 to <4 x double>*
  %163 = load <4 x double>, <4 x double>* %162, align 1, !tbaa !13
  %164 = fadd <4 x double> %159, %163
  %165 = add nuw nsw i64 %133, 24
  %166 = getelementptr inbounds double, double* %119, i64 %165
  %167 = bitcast double* %166 to <4 x double>*
  %168 = load <4 x double>, <4 x double>* %167, align 1, !tbaa !13
  %169 = fadd <4 x double> %164, %168
  %170 = add nuw nsw i64 %133, 28
  %171 = getelementptr inbounds double, double* %119, i64 %170
  %172 = bitcast double* %171 to <4 x double>*
  %173 = load <4 x double>, <4 x double>* %172, align 1, !tbaa !13
  %174 = fadd <4 x double> %169, %173
  %175 = add nuw nsw i64 %133, 32
  %176 = add i64 %135, 8
  %177 = icmp eq i64 %176, %131
  br i1 %177, label %178, label %132, !llvm.loop !25

178:                                              ; preds = %132, %123
  %179 = phi <4 x double> [ undef, %123 ], [ %174, %132 ]
  %180 = phi i64 [ 4, %123 ], [ %175, %132 ]
  %181 = phi <4 x double> [ %121, %123 ], [ %174, %132 ]
  %182 = icmp eq i64 %128, 0
  br i1 %182, label %194, label %183

183:                                              ; preds = %178, %183
  %184 = phi i64 [ %191, %183 ], [ %180, %178 ]
  %185 = phi <4 x double> [ %190, %183 ], [ %181, %178 ]
  %186 = phi i64 [ %192, %183 ], [ 0, %178 ]
  %187 = getelementptr inbounds double, double* %119, i64 %184
  %188 = bitcast double* %187 to <4 x double>*
  %189 = load <4 x double>, <4 x double>* %188, align 1, !tbaa !13
  %190 = fadd <4 x double> %185, %189
  %191 = add nuw nsw i64 %184, 4
  %192 = add i64 %186, 1
  %193 = icmp eq i64 %192, %128
  br i1 %193, label %194, label %183, !llvm.loop !26

194:                                              ; preds = %178, %183, %116
  %195 = phi <4 x double> [ %121, %116 ], [ %179, %178 ], [ %190, %183 ]
  %196 = bitcast <4 x double>* %2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %196)
  store <4 x double> zeroinitializer, <4 x double>* %2, align 16
  %197 = sext i32 %117 to i64
  %198 = getelementptr double, double* %119, i64 %197
  %199 = bitcast double* %198 to i8*
  %200 = shl i32 %6, 3
  %201 = and i32 %200, 24
  %202 = zext i32 %201 to i64
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 %196, i8* align 8 %199, i64 %202, i1 false), !tbaa !18
  %203 = load <4 x double>, <4 x double>* %2, align 16, !tbaa !13
  %204 = fadd <4 x double> %195, %203
  %205 = shufflevector <4 x double> %204, <4 x double> poison, <2 x i32> <i32 0, i32 1>
  %206 = shufflevector <4 x double> %204, <4 x double> poison, <2 x i32> <i32 2, i32 3>
  %207 = fadd <2 x double> %205, %206
  %208 = shufflevector <2 x double> %207, <2 x double> poison, <2 x i32> <i32 1, i32 undef>
  %209 = fadd <2 x double> %207, %208
  %210 = extractelement <2 x double> %209, i64 0
  %211 = fadd double %210, 0.000000e+00
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %196)
  br label %212

212:                                              ; preds = %12, %18, %23, %10, %194, %61, %1, %4
  %213 = phi double [ 0.000000e+00, %4 ], [ 0.000000e+00, %1 ], [ %69, %61 ], [ %211, %194 ], [ 0.000000e+00, %10 ], [ %16, %12 ], [ %21, %18 ], [ %26, %23 ]
  ret double %213
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind uwtable willreturn writeonly
define dso_local void @avx2_double_sum_reset(%struct.AVX2DoubleSumBuffer* noundef writeonly %0) local_unnamed_addr #6 {
  %2 = icmp eq %struct.AVX2DoubleSumBuffer* %0, null
  br i1 %2, label %5, label %3

3:                                                ; preds = %1
  %4 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 2
  store i32 0, i32* %4, align 4, !tbaa !12
  br label %5

5:                                                ; preds = %1, %3
  ret void
}

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local void @avx2_double_sum_flush(%struct.AVX2DoubleSumBuffer* noundef %0) local_unnamed_addr #4 {
  %2 = icmp eq %struct.AVX2DoubleSumBuffer* %0, null
  br i1 %2, label %90, label %3

3:                                                ; preds = %1
  %4 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 2
  %5 = load i32, i32* %4, align 4, !tbaa !12
  %6 = icmp slt i32 %5, 5
  br i1 %6, label %90, label %7

7:                                                ; preds = %3
  %8 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, %struct.AVX2DoubleSumBuffer* %0, i64 0, i32 0
  %9 = load double*, double** %8, align 8, !tbaa !5
  %10 = icmp ugt i32 %5, 7
  %11 = and i32 %5, 3
  %12 = icmp eq i32 %11, 0
  %13 = and i1 %10, %12
  br i1 %13, label %14, label %89

14:                                               ; preds = %7
  %15 = bitcast double* %9 to <4 x double>*
  %16 = load <4 x double>, <4 x double>* %15, align 1, !tbaa !13
  %17 = zext i32 %5 to i64
  %18 = add nsw i64 %17, -5
  %19 = lshr i64 %18, 2
  %20 = add nuw nsw i64 %19, 1
  %21 = and i64 %20, 7
  %22 = icmp ult i64 %18, 28
  br i1 %22, label %25, label %23

23:                                               ; preds = %14
  %24 = and i64 %20, 9223372036854775800
  br label %43

25:                                               ; preds = %43, %14
  %26 = phi <4 x double> [ undef, %14 ], [ %85, %43 ]
  %27 = phi i64 [ 4, %14 ], [ %86, %43 ]
  %28 = phi <4 x double> [ %16, %14 ], [ %85, %43 ]
  %29 = icmp eq i64 %21, 0
  br i1 %29, label %41, label %30

30:                                               ; preds = %25, %30
  %31 = phi i64 [ %38, %30 ], [ %27, %25 ]
  %32 = phi <4 x double> [ %37, %30 ], [ %28, %25 ]
  %33 = phi i64 [ %39, %30 ], [ 0, %25 ]
  %34 = getelementptr inbounds double, double* %9, i64 %31
  %35 = bitcast double* %34 to <4 x double>*
  %36 = load <4 x double>, <4 x double>* %35, align 1, !tbaa !13
  %37 = fadd <4 x double> %32, %36
  %38 = add nuw nsw i64 %31, 4
  %39 = add i64 %33, 1
  %40 = icmp eq i64 %39, %21
  br i1 %40, label %41, label %30, !llvm.loop !27

41:                                               ; preds = %30, %25
  %42 = phi <4 x double> [ %26, %25 ], [ %37, %30 ]
  store <4 x double> %42, <4 x double>* %15, align 1, !tbaa !13
  br label %89

43:                                               ; preds = %43, %23
  %44 = phi i64 [ 4, %23 ], [ %86, %43 ]
  %45 = phi <4 x double> [ %16, %23 ], [ %85, %43 ]
  %46 = phi i64 [ 0, %23 ], [ %87, %43 ]
  %47 = getelementptr inbounds double, double* %9, i64 %44
  %48 = bitcast double* %47 to <4 x double>*
  %49 = load <4 x double>, <4 x double>* %48, align 1, !tbaa !13
  %50 = fadd <4 x double> %45, %49
  %51 = add nuw nsw i64 %44, 4
  %52 = getelementptr inbounds double, double* %9, i64 %51
  %53 = bitcast double* %52 to <4 x double>*
  %54 = load <4 x double>, <4 x double>* %53, align 1, !tbaa !13
  %55 = fadd <4 x double> %50, %54
  %56 = add nuw nsw i64 %44, 8
  %57 = getelementptr inbounds double, double* %9, i64 %56
  %58 = bitcast double* %57 to <4 x double>*
  %59 = load <4 x double>, <4 x double>* %58, align 1, !tbaa !13
  %60 = fadd <4 x double> %55, %59
  %61 = add nuw nsw i64 %44, 12
  %62 = getelementptr inbounds double, double* %9, i64 %61
  %63 = bitcast double* %62 to <4 x double>*
  %64 = load <4 x double>, <4 x double>* %63, align 1, !tbaa !13
  %65 = fadd <4 x double> %60, %64
  %66 = add nuw nsw i64 %44, 16
  %67 = getelementptr inbounds double, double* %9, i64 %66
  %68 = bitcast double* %67 to <4 x double>*
  %69 = load <4 x double>, <4 x double>* %68, align 1, !tbaa !13
  %70 = fadd <4 x double> %65, %69
  %71 = add nuw nsw i64 %44, 20
  %72 = getelementptr inbounds double, double* %9, i64 %71
  %73 = bitcast double* %72 to <4 x double>*
  %74 = load <4 x double>, <4 x double>* %73, align 1, !tbaa !13
  %75 = fadd <4 x double> %70, %74
  %76 = add nuw nsw i64 %44, 24
  %77 = getelementptr inbounds double, double* %9, i64 %76
  %78 = bitcast double* %77 to <4 x double>*
  %79 = load <4 x double>, <4 x double>* %78, align 1, !tbaa !13
  %80 = fadd <4 x double> %75, %79
  %81 = add nuw nsw i64 %44, 28
  %82 = getelementptr inbounds double, double* %9, i64 %81
  %83 = bitcast double* %82 to <4 x double>*
  %84 = load <4 x double>, <4 x double>* %83, align 1, !tbaa !13
  %85 = fadd <4 x double> %80, %84
  %86 = add nuw nsw i64 %44, 32
  %87 = add i64 %46, 8
  %88 = icmp eq i64 %87, %24
  br i1 %88, label %25, label %43, !llvm.loop !16

89:                                               ; preds = %7, %41
  store i32 4, i32* %4, align 4, !tbaa !12
  br label %90

90:                                               ; preds = %1, %3, %89
  ret void
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #7

attributes #0 = { mustprogress nounwind uwtable willreturn "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { inaccessiblememonly mustprogress nofree nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #3 = { inaccessiblemem_or_argmemonly mustprogress nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #4 = { nofree norecurse nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="256" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #5 = { nofree nosync nounwind readonly uwtable "frame-pointer"="none" "min-legal-vector-width"="256" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #6 = { mustprogress nofree norecurse nosync nounwind uwtable willreturn writeonly "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #7 = { argmemonly nofree nounwind willreturn }
attributes #8 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
!5 = !{!6, !7, i64 0}
!6 = !{!"", !7, i64 0, !10, i64 8, !10, i64 12}
!7 = !{!"any pointer", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = !{!"int", !8, i64 0}
!11 = !{!6, !10, i64 8}
!12 = !{!6, !10, i64 12}
!13 = !{!8, !8, i64 0}
!14 = distinct !{!14, !15}
!15 = !{!"llvm.loop.unroll.disable"}
!16 = distinct !{!16, !17}
!17 = !{!"llvm.loop.mustprogress"}
!18 = !{!19, !19, i64 0}
!19 = !{!"double", !8, i64 0}
!20 = distinct !{!20, !15}
!21 = distinct !{!21, !17}
!22 = distinct !{!22, !17}
!23 = distinct !{!23, !15}
!24 = distinct !{!24, !17}
!25 = distinct !{!25, !17}
!26 = distinct !{!26, !15}
!27 = distinct !{!27, !15}
