; ModuleID = 'avx2_double_simd_sum.c'
source_filename = "avx2_double_simd_sum.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.AVX2DoubleSumBuffer = type { ptr, i32, i32 }

; Function Attrs: mustprogress nounwind willreturn memory(readwrite, argmem: none) uwtable
define dso_local noalias noundef ptr @avx2_double_sum_create(i32 noundef %0) local_unnamed_addr #0 {
  %2 = icmp slt i32 %0, 1
  %3 = add nsw i32 %0, 3
  %4 = and i32 %3, -4
  %5 = select i1 %2, i32 8, i32 %4
  %6 = tail call noalias dereferenceable_or_null(16) ptr @malloc(i64 noundef 16) #9
  %7 = icmp eq ptr %6, null
  br i1 %7, label %17, label %8

8:                                                ; preds = %1
  %9 = sext i32 %5 to i64
  %10 = shl nsw i64 %9, 3
  %11 = tail call noalias align 32 ptr @aligned_alloc(i64 noundef 32, i64 noundef %10) #10
  store ptr %11, ptr %6, align 8, !tbaa !5
  %12 = icmp eq ptr %11, null
  br i1 %12, label %13, label %14

13:                                               ; preds = %8
  tail call void @free(ptr noundef nonnull %6) #11
  br label %17

14:                                               ; preds = %8
  %15 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, ptr %6, i64 0, i32 1
  store i32 %5, ptr %15, align 8, !tbaa !11
  %16 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, ptr %6, i64 0, i32 2
  store i32 0, ptr %16, align 4, !tbaa !12
  br label %17

17:                                               ; preds = %1, %14, %13
  %18 = phi ptr [ %6, %14 ], [ null, %13 ], [ null, %1 ]
  ret ptr %18
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #2

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized,aligned") allocsize(1) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @aligned_alloc(i64 allocalign noundef, i64 noundef) local_unnamed_addr #3

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #4

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nounwind willreturn uwtable
define dso_local void @avx2_double_sum_destroy(ptr noundef %0) local_unnamed_addr #5 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %8, label %3

3:                                                ; preds = %1
  %4 = load ptr, ptr %0, align 8, !tbaa !5
  %5 = icmp eq ptr %4, null
  br i1 %5, label %7, label %6

6:                                                ; preds = %3
  tail call void @free(ptr noundef nonnull %4) #11
  br label %7

7:                                                ; preds = %6, %3
  tail call void @free(ptr noundef nonnull %0) #11
  br label %8

8:                                                ; preds = %7, %1
  ret void
}

; Function Attrs: nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable
define dso_local void @avx2_double_sum_add(ptr noundef %0, double noundef %1) local_unnamed_addr #6 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %90, label %4

4:                                                ; preds = %2
  %5 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, ptr %0, i64 0, i32 2
  %6 = load i32, ptr %5, align 4, !tbaa !12
  %7 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, ptr %0, i64 0, i32 1
  %8 = load i32, ptr %7, align 8, !tbaa !11
  %9 = icmp sge i32 %6, %8
  %10 = icmp sgt i32 %6, 3
  %11 = and i1 %10, %9
  %12 = load ptr, ptr %0, align 8, !tbaa !5
  br i1 %11, label %13, label %84

13:                                               ; preds = %4
  %14 = icmp ugt i32 %6, 7
  %15 = and i32 %6, 3
  %16 = icmp eq i32 %15, 0
  %17 = and i1 %14, %16
  br i1 %17, label %18, label %84

18:                                               ; preds = %13
  %19 = load <4 x double>, ptr %12, align 1, !tbaa !13
  %20 = zext nneg i32 %6 to i64
  %21 = add nsw i64 %20, -5
  %22 = lshr i64 %21, 2
  %23 = add nuw nsw i64 %22, 1
  %24 = and i64 %23, 7
  %25 = icmp ult i64 %21, 28
  br i1 %25, label %35, label %26

26:                                               ; preds = %18
  %27 = and i64 %23, 9223372036854775800
  %28 = getelementptr double, ptr %12, i64 4
  %29 = getelementptr double, ptr %12, i64 8
  %30 = getelementptr double, ptr %12, i64 12
  %31 = getelementptr double, ptr %12, i64 16
  %32 = getelementptr double, ptr %12, i64 20
  %33 = getelementptr double, ptr %12, i64 24
  %34 = getelementptr double, ptr %12, i64 28
  br label %53

35:                                               ; preds = %53, %18
  %36 = phi <4 x double> [ undef, %18 ], [ %80, %53 ]
  %37 = phi i64 [ 4, %18 ], [ %81, %53 ]
  %38 = phi <4 x double> [ %19, %18 ], [ %80, %53 ]
  %39 = icmp eq i64 %24, 0
  br i1 %39, label %50, label %40

40:                                               ; preds = %35, %40
  %41 = phi i64 [ %47, %40 ], [ %37, %35 ]
  %42 = phi <4 x double> [ %46, %40 ], [ %38, %35 ]
  %43 = phi i64 [ %48, %40 ], [ 0, %35 ]
  %44 = getelementptr inbounds double, ptr %12, i64 %41
  %45 = load <4 x double>, ptr %44, align 1, !tbaa !13
  %46 = fadd <4 x double> %42, %45
  %47 = add nuw nsw i64 %41, 4
  %48 = add i64 %43, 1
  %49 = icmp eq i64 %48, %24
  br i1 %49, label %50, label %40, !llvm.loop !14

50:                                               ; preds = %40, %35
  %51 = phi <4 x double> [ %36, %35 ], [ %46, %40 ]
  store <4 x double> %51, ptr %12, align 1, !tbaa !13
  %52 = load ptr, ptr %0, align 8, !tbaa !5
  br label %84

53:                                               ; preds = %53, %26
  %54 = phi i64 [ 4, %26 ], [ %81, %53 ]
  %55 = phi <4 x double> [ %19, %26 ], [ %80, %53 ]
  %56 = phi i64 [ 0, %26 ], [ %82, %53 ]
  %57 = getelementptr inbounds double, ptr %12, i64 %54
  %58 = load <4 x double>, ptr %57, align 1, !tbaa !13
  %59 = fadd <4 x double> %55, %58
  %60 = getelementptr double, ptr %28, i64 %54
  %61 = load <4 x double>, ptr %60, align 1, !tbaa !13
  %62 = fadd <4 x double> %59, %61
  %63 = getelementptr double, ptr %29, i64 %54
  %64 = load <4 x double>, ptr %63, align 1, !tbaa !13
  %65 = fadd <4 x double> %62, %64
  %66 = getelementptr double, ptr %30, i64 %54
  %67 = load <4 x double>, ptr %66, align 1, !tbaa !13
  %68 = fadd <4 x double> %65, %67
  %69 = getelementptr double, ptr %31, i64 %54
  %70 = load <4 x double>, ptr %69, align 1, !tbaa !13
  %71 = fadd <4 x double> %68, %70
  %72 = getelementptr double, ptr %32, i64 %54
  %73 = load <4 x double>, ptr %72, align 1, !tbaa !13
  %74 = fadd <4 x double> %71, %73
  %75 = getelementptr double, ptr %33, i64 %54
  %76 = load <4 x double>, ptr %75, align 1, !tbaa !13
  %77 = fadd <4 x double> %74, %76
  %78 = getelementptr double, ptr %34, i64 %54
  %79 = load <4 x double>, ptr %78, align 1, !tbaa !13
  %80 = fadd <4 x double> %77, %79
  %81 = add nuw nsw i64 %54, 32
  %82 = add i64 %56, 8
  %83 = icmp eq i64 %82, %27
  br i1 %83, label %35, label %53, !llvm.loop !16

84:                                               ; preds = %50, %13, %4
  %85 = phi i32 [ %6, %4 ], [ 4, %13 ], [ 4, %50 ]
  %86 = phi ptr [ %12, %4 ], [ %12, %13 ], [ %52, %50 ]
  %87 = sext i32 %85 to i64
  %88 = getelementptr inbounds double, ptr %86, i64 %87
  store double %1, ptr %88, align 8, !tbaa !18
  %89 = add nsw i32 %85, 1
  store i32 %89, ptr %5, align 4, !tbaa !12
  br label %90

90:                                               ; preds = %2, %84
  ret void
}

; Function Attrs: nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable
define dso_local void @avx2_double_sum_add_batch(ptr noundef %0, ptr noundef readonly %1, i32 noundef %2) local_unnamed_addr #6 {
  %4 = icmp eq ptr %0, null
  %5 = icmp eq ptr %1, null
  %6 = icmp slt i32 %2, 1
  %7 = or i1 %5, %6
  %8 = or i1 %4, %7
  br i1 %8, label %104, label %9

9:                                                ; preds = %3
  %10 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, ptr %0, i64 0, i32 2
  %11 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, ptr %0, i64 0, i32 1
  %12 = zext nneg i32 %2 to i64
  %13 = load i32, ptr %10, align 4, !tbaa !12
  %14 = load ptr, ptr %0, align 8, !tbaa !5
  br label %15

15:                                               ; preds = %9, %96
  %16 = phi ptr [ %14, %9 ], [ %97, %96 ]
  %17 = phi i32 [ %13, %9 ], [ %101, %96 ]
  %18 = phi i64 [ 0, %9 ], [ %102, %96 ]
  %19 = getelementptr inbounds double, ptr %1, i64 %18
  %20 = load double, ptr %19, align 8, !tbaa !18
  %21 = load i32, ptr %11, align 8, !tbaa !11
  %22 = icmp sge i32 %17, %21
  %23 = icmp sgt i32 %17, 3
  %24 = and i1 %23, %22
  br i1 %24, label %25, label %96

25:                                               ; preds = %15
  %26 = icmp ugt i32 %17, 7
  %27 = and i32 %17, 3
  %28 = icmp eq i32 %27, 0
  %29 = and i1 %26, %28
  br i1 %29, label %30, label %96

30:                                               ; preds = %25
  %31 = load <4 x double>, ptr %16, align 1, !tbaa !13
  %32 = zext nneg i32 %17 to i64
  %33 = add nsw i64 %32, -5
  %34 = lshr i64 %33, 2
  %35 = add nuw nsw i64 %34, 1
  %36 = and i64 %35, 7
  %37 = icmp ult i64 %33, 28
  br i1 %37, label %40, label %38

38:                                               ; preds = %30
  %39 = and i64 %35, 9223372036854775800
  br label %58

40:                                               ; preds = %58, %30
  %41 = phi <4 x double> [ undef, %30 ], [ %92, %58 ]
  %42 = phi i64 [ 4, %30 ], [ %93, %58 ]
  %43 = phi <4 x double> [ %31, %30 ], [ %92, %58 ]
  %44 = icmp eq i64 %36, 0
  br i1 %44, label %55, label %45

45:                                               ; preds = %40, %45
  %46 = phi i64 [ %52, %45 ], [ %42, %40 ]
  %47 = phi <4 x double> [ %51, %45 ], [ %43, %40 ]
  %48 = phi i64 [ %53, %45 ], [ 0, %40 ]
  %49 = getelementptr inbounds double, ptr %16, i64 %46
  %50 = load <4 x double>, ptr %49, align 1, !tbaa !13
  %51 = fadd <4 x double> %47, %50
  %52 = add nuw nsw i64 %46, 4
  %53 = add i64 %48, 1
  %54 = icmp eq i64 %53, %36
  br i1 %54, label %55, label %45, !llvm.loop !20

55:                                               ; preds = %45, %40
  %56 = phi <4 x double> [ %41, %40 ], [ %51, %45 ]
  store <4 x double> %56, ptr %16, align 1, !tbaa !13
  %57 = load ptr, ptr %0, align 8, !tbaa !5
  br label %96

58:                                               ; preds = %58, %38
  %59 = phi i64 [ 4, %38 ], [ %93, %58 ]
  %60 = phi <4 x double> [ %31, %38 ], [ %92, %58 ]
  %61 = phi i64 [ 0, %38 ], [ %94, %58 ]
  %62 = getelementptr inbounds double, ptr %16, i64 %59
  %63 = load <4 x double>, ptr %62, align 1, !tbaa !13
  %64 = fadd <4 x double> %60, %63
  %65 = add nuw nsw i64 %59, 4
  %66 = getelementptr inbounds double, ptr %16, i64 %65
  %67 = load <4 x double>, ptr %66, align 1, !tbaa !13
  %68 = fadd <4 x double> %64, %67
  %69 = add nuw nsw i64 %59, 8
  %70 = getelementptr inbounds double, ptr %16, i64 %69
  %71 = load <4 x double>, ptr %70, align 1, !tbaa !13
  %72 = fadd <4 x double> %68, %71
  %73 = add nuw nsw i64 %59, 12
  %74 = getelementptr inbounds double, ptr %16, i64 %73
  %75 = load <4 x double>, ptr %74, align 1, !tbaa !13
  %76 = fadd <4 x double> %72, %75
  %77 = add nuw nsw i64 %59, 16
  %78 = getelementptr inbounds double, ptr %16, i64 %77
  %79 = load <4 x double>, ptr %78, align 1, !tbaa !13
  %80 = fadd <4 x double> %76, %79
  %81 = add nuw nsw i64 %59, 20
  %82 = getelementptr inbounds double, ptr %16, i64 %81
  %83 = load <4 x double>, ptr %82, align 1, !tbaa !13
  %84 = fadd <4 x double> %80, %83
  %85 = add nuw nsw i64 %59, 24
  %86 = getelementptr inbounds double, ptr %16, i64 %85
  %87 = load <4 x double>, ptr %86, align 1, !tbaa !13
  %88 = fadd <4 x double> %84, %87
  %89 = add nuw nsw i64 %59, 28
  %90 = getelementptr inbounds double, ptr %16, i64 %89
  %91 = load <4 x double>, ptr %90, align 1, !tbaa !13
  %92 = fadd <4 x double> %88, %91
  %93 = add nuw nsw i64 %59, 32
  %94 = add i64 %61, 8
  %95 = icmp eq i64 %94, %39
  br i1 %95, label %40, label %58, !llvm.loop !16

96:                                               ; preds = %55, %25, %15
  %97 = phi ptr [ %16, %15 ], [ %16, %25 ], [ %57, %55 ]
  %98 = phi i32 [ %17, %15 ], [ 4, %25 ], [ 4, %55 ]
  %99 = sext i32 %98 to i64
  %100 = getelementptr inbounds double, ptr %97, i64 %99
  store double %20, ptr %100, align 8, !tbaa !18
  %101 = add nsw i32 %98, 1
  store i32 %101, ptr %10, align 4, !tbaa !12
  %102 = add nuw nsw i64 %18, 1
  %103 = icmp eq i64 %102, %12
  br i1 %103, label %104, label %15, !llvm.loop !21

104:                                              ; preds = %96, %3
  ret void
}

; Function Attrs: nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable
define dso_local double @avx2_double_sum_get_result(ptr noundef readonly %0) local_unnamed_addr #6 {
  %2 = alloca <4 x double>, align 32
  %3 = icmp eq ptr %0, null
  br i1 %3, label %137, label %4

4:                                                ; preds = %1
  %5 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, ptr %0, i64 0, i32 2
  %6 = load i32, ptr %5, align 4, !tbaa !12
  %7 = icmp eq i32 %6, 0
  br i1 %7, label %137, label %8

8:                                                ; preds = %4
  %9 = icmp slt i32 %6, 4
  br i1 %9, label %10, label %26

10:                                               ; preds = %8
  %11 = icmp sgt i32 %6, 0
  br i1 %11, label %12, label %137

12:                                               ; preds = %10
  %13 = load ptr, ptr %0, align 8, !tbaa !5
  %14 = load double, ptr %13, align 8, !tbaa !18
  %15 = fadd double %14, 0.000000e+00
  %16 = icmp eq i32 %6, 1
  br i1 %16, label %137, label %17, !llvm.loop !22

17:                                               ; preds = %12
  %18 = getelementptr inbounds double, ptr %13, i64 1
  %19 = load double, ptr %18, align 8, !tbaa !18
  %20 = fadd double %15, %19
  %21 = icmp eq i32 %6, 2
  br i1 %21, label %137, label %22, !llvm.loop !22

22:                                               ; preds = %17
  %23 = getelementptr inbounds double, ptr %13, i64 2
  %24 = load double, ptr %23, align 8, !tbaa !18
  %25 = fadd double %20, %24
  br label %137

26:                                               ; preds = %8
  %27 = and i32 %6, 3
  %28 = icmp eq i32 %27, 0
  br i1 %28, label %29, label %52

29:                                               ; preds = %26
  %30 = load ptr, ptr %0, align 8, !tbaa !5
  %31 = load <4 x double>, ptr %30, align 1, !tbaa !13
  %32 = icmp eq i32 %6, 4
  br i1 %32, label %35, label %33

33:                                               ; preds = %29
  %34 = zext nneg i32 %6 to i64
  br label %44

35:                                               ; preds = %44, %29
  %36 = phi <4 x double> [ %31, %29 ], [ %49, %44 ]
  %37 = shufflevector <4 x double> %36, <4 x double> poison, <2 x i32> <i32 0, i32 1>
  %38 = shufflevector <4 x double> %36, <4 x double> poison, <2 x i32> <i32 2, i32 3>
  %39 = fadd <2 x double> %37, %38
  %40 = shufflevector <2 x double> %39, <2 x double> poison, <2 x i32> <i32 1, i32 poison>
  %41 = fadd <2 x double> %39, %40
  %42 = extractelement <2 x double> %41, i64 0
  %43 = fadd double %42, 0.000000e+00
  br label %137

44:                                               ; preds = %33, %44
  %45 = phi i64 [ 4, %33 ], [ %50, %44 ]
  %46 = phi <4 x double> [ %31, %33 ], [ %49, %44 ]
  %47 = getelementptr inbounds double, ptr %30, i64 %45
  %48 = load <4 x double>, ptr %47, align 1, !tbaa !13
  %49 = fadd <4 x double> %46, %48
  %50 = add nuw nsw i64 %45, 4
  %51 = icmp ult i64 %50, %34
  br i1 %51, label %44, label %35, !llvm.loop !23

52:                                               ; preds = %26
  %53 = and i32 %6, 2147483644
  %54 = load ptr, ptr %0, align 8, !tbaa !5
  %55 = load <4 x double>, ptr %54, align 1, !tbaa !13
  %56 = icmp ugt i32 %53, 4
  br i1 %56, label %57, label %119

57:                                               ; preds = %52
  %58 = zext nneg i32 %53 to i64
  %59 = add nsw i64 %58, -5
  %60 = lshr i64 %59, 2
  %61 = add nuw nsw i64 %60, 1
  %62 = and i64 %61, 7
  %63 = icmp ult i64 %59, 28
  br i1 %63, label %104, label %64

64:                                               ; preds = %57
  %65 = and i64 %61, 9223372036854775800
  %66 = getelementptr double, ptr %54, i64 4
  %67 = getelementptr double, ptr %54, i64 8
  %68 = getelementptr double, ptr %54, i64 12
  %69 = getelementptr double, ptr %54, i64 16
  %70 = getelementptr double, ptr %54, i64 20
  %71 = getelementptr double, ptr %54, i64 24
  %72 = getelementptr double, ptr %54, i64 28
  br label %73

73:                                               ; preds = %73, %64
  %74 = phi i64 [ 4, %64 ], [ %101, %73 ]
  %75 = phi <4 x double> [ %55, %64 ], [ %100, %73 ]
  %76 = phi i64 [ 0, %64 ], [ %102, %73 ]
  %77 = getelementptr inbounds double, ptr %54, i64 %74
  %78 = load <4 x double>, ptr %77, align 1, !tbaa !13
  %79 = fadd <4 x double> %75, %78
  %80 = getelementptr double, ptr %66, i64 %74
  %81 = load <4 x double>, ptr %80, align 1, !tbaa !13
  %82 = fadd <4 x double> %79, %81
  %83 = getelementptr double, ptr %67, i64 %74
  %84 = load <4 x double>, ptr %83, align 1, !tbaa !13
  %85 = fadd <4 x double> %82, %84
  %86 = getelementptr double, ptr %68, i64 %74
  %87 = load <4 x double>, ptr %86, align 1, !tbaa !13
  %88 = fadd <4 x double> %85, %87
  %89 = getelementptr double, ptr %69, i64 %74
  %90 = load <4 x double>, ptr %89, align 1, !tbaa !13
  %91 = fadd <4 x double> %88, %90
  %92 = getelementptr double, ptr %70, i64 %74
  %93 = load <4 x double>, ptr %92, align 1, !tbaa !13
  %94 = fadd <4 x double> %91, %93
  %95 = getelementptr double, ptr %71, i64 %74
  %96 = load <4 x double>, ptr %95, align 1, !tbaa !13
  %97 = fadd <4 x double> %94, %96
  %98 = getelementptr double, ptr %72, i64 %74
  %99 = load <4 x double>, ptr %98, align 1, !tbaa !13
  %100 = fadd <4 x double> %97, %99
  %101 = add nuw nsw i64 %74, 32
  %102 = add i64 %76, 8
  %103 = icmp eq i64 %102, %65
  br i1 %103, label %104, label %73, !llvm.loop !24

104:                                              ; preds = %73, %57
  %105 = phi <4 x double> [ undef, %57 ], [ %100, %73 ]
  %106 = phi i64 [ 4, %57 ], [ %101, %73 ]
  %107 = phi <4 x double> [ %55, %57 ], [ %100, %73 ]
  %108 = icmp eq i64 %62, 0
  br i1 %108, label %119, label %109

109:                                              ; preds = %104, %109
  %110 = phi i64 [ %116, %109 ], [ %106, %104 ]
  %111 = phi <4 x double> [ %115, %109 ], [ %107, %104 ]
  %112 = phi i64 [ %117, %109 ], [ 0, %104 ]
  %113 = getelementptr inbounds double, ptr %54, i64 %110
  %114 = load <4 x double>, ptr %113, align 1, !tbaa !13
  %115 = fadd <4 x double> %111, %114
  %116 = add nuw nsw i64 %110, 4
  %117 = add i64 %112, 1
  %118 = icmp eq i64 %117, %62
  br i1 %118, label %119, label %109, !llvm.loop !25

119:                                              ; preds = %104, %109, %52
  %120 = phi <4 x double> [ %55, %52 ], [ %105, %104 ], [ %115, %109 ]
  call void @llvm.lifetime.start.p0(i64 32, ptr nonnull %2)
  store <4 x double> zeroinitializer, ptr %2, align 32
  %121 = lshr i32 %6, 2
  %122 = zext nneg i32 %121 to i64
  %123 = shl nuw nsw i64 %122, 5
  %124 = getelementptr i8, ptr %54, i64 %123
  %125 = shl i32 %6, 3
  %126 = and i32 %125, 24
  %127 = zext nneg i32 %126 to i64
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 32 %2, ptr align 8 %124, i64 %127, i1 false), !tbaa !18
  %128 = load <4 x double>, ptr %2, align 32, !tbaa !13
  %129 = fadd <4 x double> %120, %128
  %130 = shufflevector <4 x double> %129, <4 x double> poison, <2 x i32> <i32 0, i32 1>
  %131 = shufflevector <4 x double> %129, <4 x double> poison, <2 x i32> <i32 2, i32 3>
  %132 = fadd <2 x double> %130, %131
  %133 = shufflevector <2 x double> %132, <2 x double> poison, <2 x i32> <i32 1, i32 poison>
  %134 = fadd <2 x double> %132, %133
  %135 = extractelement <2 x double> %134, i64 0
  %136 = fadd double %135, 0.000000e+00
  call void @llvm.lifetime.end.p0(i64 32, ptr nonnull %2)
  br label %137

137:                                              ; preds = %12, %17, %22, %10, %119, %35, %1, %4
  %138 = phi double [ 0.000000e+00, %4 ], [ 0.000000e+00, %1 ], [ %43, %35 ], [ %136, %119 ], [ 0.000000e+00, %10 ], [ %15, %12 ], [ %20, %17 ], [ %25, %22 ]
  ret double %138
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) uwtable
define dso_local void @avx2_double_sum_reset(ptr noundef writeonly %0) local_unnamed_addr #7 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %5, label %3

3:                                                ; preds = %1
  %4 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, ptr %0, i64 0, i32 2
  store i32 0, ptr %4, align 4, !tbaa !12
  br label %5

5:                                                ; preds = %1, %3
  ret void
}

; Function Attrs: nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable
define dso_local void @avx2_double_sum_flush(ptr noundef %0) local_unnamed_addr #6 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %79, label %3

3:                                                ; preds = %1
  %4 = getelementptr inbounds %struct.AVX2DoubleSumBuffer, ptr %0, i64 0, i32 2
  %5 = load i32, ptr %4, align 4, !tbaa !12
  %6 = icmp slt i32 %5, 5
  br i1 %6, label %79, label %7

7:                                                ; preds = %3
  %8 = load ptr, ptr %0, align 8, !tbaa !5
  %9 = icmp ugt i32 %5, 7
  %10 = and i32 %5, 3
  %11 = icmp eq i32 %10, 0
  %12 = and i1 %9, %11
  br i1 %12, label %13, label %78

13:                                               ; preds = %7
  %14 = load <4 x double>, ptr %8, align 1, !tbaa !13
  %15 = zext nneg i32 %5 to i64
  %16 = add nsw i64 %15, -5
  %17 = lshr i64 %16, 2
  %18 = add nuw nsw i64 %17, 1
  %19 = and i64 %18, 7
  %20 = icmp ult i64 %16, 28
  br i1 %20, label %30, label %21

21:                                               ; preds = %13
  %22 = and i64 %18, 9223372036854775800
  %23 = getelementptr double, ptr %8, i64 4
  %24 = getelementptr double, ptr %8, i64 8
  %25 = getelementptr double, ptr %8, i64 12
  %26 = getelementptr double, ptr %8, i64 16
  %27 = getelementptr double, ptr %8, i64 20
  %28 = getelementptr double, ptr %8, i64 24
  %29 = getelementptr double, ptr %8, i64 28
  br label %47

30:                                               ; preds = %47, %13
  %31 = phi <4 x double> [ undef, %13 ], [ %74, %47 ]
  %32 = phi i64 [ 4, %13 ], [ %75, %47 ]
  %33 = phi <4 x double> [ %14, %13 ], [ %74, %47 ]
  %34 = icmp eq i64 %19, 0
  br i1 %34, label %45, label %35

35:                                               ; preds = %30, %35
  %36 = phi i64 [ %42, %35 ], [ %32, %30 ]
  %37 = phi <4 x double> [ %41, %35 ], [ %33, %30 ]
  %38 = phi i64 [ %43, %35 ], [ 0, %30 ]
  %39 = getelementptr inbounds double, ptr %8, i64 %36
  %40 = load <4 x double>, ptr %39, align 1, !tbaa !13
  %41 = fadd <4 x double> %37, %40
  %42 = add nuw nsw i64 %36, 4
  %43 = add i64 %38, 1
  %44 = icmp eq i64 %43, %19
  br i1 %44, label %45, label %35, !llvm.loop !26

45:                                               ; preds = %35, %30
  %46 = phi <4 x double> [ %31, %30 ], [ %41, %35 ]
  store <4 x double> %46, ptr %8, align 1, !tbaa !13
  br label %78

47:                                               ; preds = %47, %21
  %48 = phi i64 [ 4, %21 ], [ %75, %47 ]
  %49 = phi <4 x double> [ %14, %21 ], [ %74, %47 ]
  %50 = phi i64 [ 0, %21 ], [ %76, %47 ]
  %51 = getelementptr inbounds double, ptr %8, i64 %48
  %52 = load <4 x double>, ptr %51, align 1, !tbaa !13
  %53 = fadd <4 x double> %49, %52
  %54 = getelementptr double, ptr %23, i64 %48
  %55 = load <4 x double>, ptr %54, align 1, !tbaa !13
  %56 = fadd <4 x double> %53, %55
  %57 = getelementptr double, ptr %24, i64 %48
  %58 = load <4 x double>, ptr %57, align 1, !tbaa !13
  %59 = fadd <4 x double> %56, %58
  %60 = getelementptr double, ptr %25, i64 %48
  %61 = load <4 x double>, ptr %60, align 1, !tbaa !13
  %62 = fadd <4 x double> %59, %61
  %63 = getelementptr double, ptr %26, i64 %48
  %64 = load <4 x double>, ptr %63, align 1, !tbaa !13
  %65 = fadd <4 x double> %62, %64
  %66 = getelementptr double, ptr %27, i64 %48
  %67 = load <4 x double>, ptr %66, align 1, !tbaa !13
  %68 = fadd <4 x double> %65, %67
  %69 = getelementptr double, ptr %28, i64 %48
  %70 = load <4 x double>, ptr %69, align 1, !tbaa !13
  %71 = fadd <4 x double> %68, %70
  %72 = getelementptr double, ptr %29, i64 %48
  %73 = load <4 x double>, ptr %72, align 1, !tbaa !13
  %74 = fadd <4 x double> %71, %73
  %75 = add nuw nsw i64 %48, 32
  %76 = add i64 %50, 8
  %77 = icmp eq i64 %76, %22
  br i1 %77, label %30, label %47, !llvm.loop !16

78:                                               ; preds = %7, %45
  store i32 4, ptr %4, align 4, !tbaa !12
  br label %79

79:                                               ; preds = %1, %3, %78
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #8

attributes #0 = { mustprogress nounwind willreturn memory(readwrite, argmem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #3 = { mustprogress nofree nounwind willreturn allockind("alloc,uninitialized,aligned") allocsize(1) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #4 = { mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #5 = { mustprogress nounwind willreturn uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #6 = { nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="256" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #7 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #8 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #9 = { nounwind allocsize(0) }
attributes #10 = { nounwind allocsize(1) }
attributes #11 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Homebrew clang version 18.1.8"}
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
!23 = distinct !{!23, !17}
!24 = distinct !{!24, !17}
!25 = distinct !{!25, !15}
!26 = distinct !{!26, !15}
