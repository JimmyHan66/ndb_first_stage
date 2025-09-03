; ModuleID = '../common/filter_kernels.c'
source_filename = "../common/filter_kernels.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.SimpleColumnView = type { i32*, i8*, i64, i64, i32 }

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local i32 @filter_le_date32(%struct.SimpleColumnView* noundef readonly %0, i32 noundef %1, i32* noundef writeonly %2) local_unnamed_addr #0 {
  %4 = icmp eq %struct.SimpleColumnView* %0, null
  br i1 %4, label %97, label %5

5:                                                ; preds = %3
  %6 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %0, i64 0, i32 0
  %7 = load i32*, i32** %6, align 8, !tbaa !5
  %8 = icmp ne i32* %7, null
  %9 = icmp ne i32* %2, null
  %10 = and i1 %9, %8
  br i1 %10, label %11, label %97

11:                                               ; preds = %5
  %12 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %0, i64 0, i32 2
  %13 = load i64, i64* %12, align 8, !tbaa !12
  %14 = icmp sgt i64 %13, 0
  br i1 %14, label %15, label %97

15:                                               ; preds = %11
  %16 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %0, i64 0, i32 3
  %17 = load i64, i64* %16, align 8, !tbaa !13
  %18 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %0, i64 0, i32 1
  %19 = load i8*, i8** %18, align 8, !tbaa !14
  %20 = icmp eq i8* %19, null
  br i1 %20, label %21, label %56

21:                                               ; preds = %15
  %22 = and i64 %13, 1
  %23 = icmp eq i64 %13, 1
  br i1 %23, label %82, label %24

24:                                               ; preds = %21
  %25 = and i64 %13, -2
  br label %26

26:                                               ; preds = %51, %24
  %27 = phi i64 [ 0, %24 ], [ %53, %51 ]
  %28 = phi i32 [ 0, %24 ], [ %52, %51 ]
  %29 = phi i64 [ 0, %24 ], [ %54, %51 ]
  %30 = add nsw i64 %17, %27
  %31 = getelementptr inbounds i32, i32* %7, i64 %30
  %32 = load i32, i32* %31, align 4, !tbaa !15
  %33 = icmp sgt i32 %32, %1
  br i1 %33, label %39, label %34

34:                                               ; preds = %26
  %35 = trunc i64 %27 to i32
  %36 = add nsw i32 %28, 1
  %37 = sext i32 %28 to i64
  %38 = getelementptr inbounds i32, i32* %2, i64 %37
  store i32 %35, i32* %38, align 4, !tbaa !15
  br label %39

39:                                               ; preds = %34, %26
  %40 = phi i32 [ %36, %34 ], [ %28, %26 ]
  %41 = or i64 %27, 1
  %42 = add nsw i64 %17, %41
  %43 = getelementptr inbounds i32, i32* %7, i64 %42
  %44 = load i32, i32* %43, align 4, !tbaa !15
  %45 = icmp sgt i32 %44, %1
  br i1 %45, label %51, label %46

46:                                               ; preds = %39
  %47 = trunc i64 %41 to i32
  %48 = add nsw i32 %40, 1
  %49 = sext i32 %40 to i64
  %50 = getelementptr inbounds i32, i32* %2, i64 %49
  store i32 %47, i32* %50, align 4, !tbaa !15
  br label %51

51:                                               ; preds = %46, %39
  %52 = phi i32 [ %48, %46 ], [ %40, %39 ]
  %53 = add nuw nsw i64 %27, 2
  %54 = add i64 %29, 2
  %55 = icmp eq i64 %54, %25
  br i1 %55, label %82, label %26, !llvm.loop !16

56:                                               ; preds = %15, %78
  %57 = phi i64 [ %80, %78 ], [ 0, %15 ]
  %58 = phi i32 [ %79, %78 ], [ 0, %15 ]
  %59 = add nsw i64 %17, %57
  %60 = sdiv i64 %59, 8
  %61 = srem i64 %59, 8
  %62 = getelementptr inbounds i8, i8* %19, i64 %60
  %63 = load i8, i8* %62, align 1, !tbaa !18
  %64 = zext i8 %63 to i32
  %65 = trunc i64 %61 to i32
  %66 = shl nuw nsw i32 1, %65
  %67 = and i32 %66, %64
  %68 = icmp eq i32 %67, 0
  br i1 %68, label %78, label %69

69:                                               ; preds = %56
  %70 = getelementptr inbounds i32, i32* %7, i64 %59
  %71 = load i32, i32* %70, align 4, !tbaa !15
  %72 = icmp sgt i32 %71, %1
  br i1 %72, label %78, label %73

73:                                               ; preds = %69
  %74 = trunc i64 %57 to i32
  %75 = add nsw i32 %58, 1
  %76 = sext i32 %58 to i64
  %77 = getelementptr inbounds i32, i32* %2, i64 %76
  store i32 %74, i32* %77, align 4, !tbaa !15
  br label %78

78:                                               ; preds = %69, %73, %56
  %79 = phi i32 [ %58, %56 ], [ %75, %73 ], [ %58, %69 ]
  %80 = add nuw nsw i64 %57, 1
  %81 = icmp eq i64 %80, %13
  br i1 %81, label %97, label %56, !llvm.loop !16

82:                                               ; preds = %51, %21
  %83 = phi i32 [ undef, %21 ], [ %52, %51 ]
  %84 = phi i64 [ 0, %21 ], [ %53, %51 ]
  %85 = phi i32 [ 0, %21 ], [ %52, %51 ]
  %86 = icmp eq i64 %22, 0
  br i1 %86, label %97, label %87

87:                                               ; preds = %82
  %88 = add nsw i64 %17, %84
  %89 = getelementptr inbounds i32, i32* %7, i64 %88
  %90 = load i32, i32* %89, align 4, !tbaa !15
  %91 = icmp sgt i32 %90, %1
  br i1 %91, label %97, label %92

92:                                               ; preds = %87
  %93 = trunc i64 %84 to i32
  %94 = add nsw i32 %85, 1
  %95 = sext i32 %85 to i64
  %96 = getelementptr inbounds i32, i32* %2, i64 %95
  store i32 %93, i32* %96, align 4, !tbaa !15
  br label %97

97:                                               ; preds = %78, %82, %92, %87, %11, %3, %5
  %98 = phi i32 [ -1, %5 ], [ -1, %3 ], [ 0, %11 ], [ %83, %82 ], [ %94, %92 ], [ %85, %87 ], [ %79, %78 ]
  ret i32 %98
}

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local i32 @filter_ge_date32(%struct.SimpleColumnView* noundef readonly %0, i32 noundef %1, i32* noundef writeonly %2) local_unnamed_addr #0 {
  %4 = icmp eq %struct.SimpleColumnView* %0, null
  br i1 %4, label %97, label %5

5:                                                ; preds = %3
  %6 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %0, i64 0, i32 0
  %7 = load i32*, i32** %6, align 8, !tbaa !5
  %8 = icmp ne i32* %7, null
  %9 = icmp ne i32* %2, null
  %10 = and i1 %9, %8
  br i1 %10, label %11, label %97

11:                                               ; preds = %5
  %12 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %0, i64 0, i32 2
  %13 = load i64, i64* %12, align 8, !tbaa !12
  %14 = icmp sgt i64 %13, 0
  br i1 %14, label %15, label %97

15:                                               ; preds = %11
  %16 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %0, i64 0, i32 3
  %17 = load i64, i64* %16, align 8, !tbaa !13
  %18 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %0, i64 0, i32 1
  %19 = load i8*, i8** %18, align 8, !tbaa !14
  %20 = icmp eq i8* %19, null
  br i1 %20, label %21, label %56

21:                                               ; preds = %15
  %22 = and i64 %13, 1
  %23 = icmp eq i64 %13, 1
  br i1 %23, label %82, label %24

24:                                               ; preds = %21
  %25 = and i64 %13, -2
  br label %26

26:                                               ; preds = %51, %24
  %27 = phi i64 [ 0, %24 ], [ %53, %51 ]
  %28 = phi i32 [ 0, %24 ], [ %52, %51 ]
  %29 = phi i64 [ 0, %24 ], [ %54, %51 ]
  %30 = add nsw i64 %17, %27
  %31 = getelementptr inbounds i32, i32* %7, i64 %30
  %32 = load i32, i32* %31, align 4, !tbaa !15
  %33 = icmp slt i32 %32, %1
  br i1 %33, label %39, label %34

34:                                               ; preds = %26
  %35 = trunc i64 %27 to i32
  %36 = add nsw i32 %28, 1
  %37 = sext i32 %28 to i64
  %38 = getelementptr inbounds i32, i32* %2, i64 %37
  store i32 %35, i32* %38, align 4, !tbaa !15
  br label %39

39:                                               ; preds = %34, %26
  %40 = phi i32 [ %36, %34 ], [ %28, %26 ]
  %41 = or i64 %27, 1
  %42 = add nsw i64 %17, %41
  %43 = getelementptr inbounds i32, i32* %7, i64 %42
  %44 = load i32, i32* %43, align 4, !tbaa !15
  %45 = icmp slt i32 %44, %1
  br i1 %45, label %51, label %46

46:                                               ; preds = %39
  %47 = trunc i64 %41 to i32
  %48 = add nsw i32 %40, 1
  %49 = sext i32 %40 to i64
  %50 = getelementptr inbounds i32, i32* %2, i64 %49
  store i32 %47, i32* %50, align 4, !tbaa !15
  br label %51

51:                                               ; preds = %46, %39
  %52 = phi i32 [ %48, %46 ], [ %40, %39 ]
  %53 = add nuw nsw i64 %27, 2
  %54 = add i64 %29, 2
  %55 = icmp eq i64 %54, %25
  br i1 %55, label %82, label %26, !llvm.loop !19

56:                                               ; preds = %15, %78
  %57 = phi i64 [ %80, %78 ], [ 0, %15 ]
  %58 = phi i32 [ %79, %78 ], [ 0, %15 ]
  %59 = add nsw i64 %17, %57
  %60 = sdiv i64 %59, 8
  %61 = srem i64 %59, 8
  %62 = getelementptr inbounds i8, i8* %19, i64 %60
  %63 = load i8, i8* %62, align 1, !tbaa !18
  %64 = zext i8 %63 to i32
  %65 = trunc i64 %61 to i32
  %66 = shl nuw nsw i32 1, %65
  %67 = and i32 %66, %64
  %68 = icmp eq i32 %67, 0
  br i1 %68, label %78, label %69

69:                                               ; preds = %56
  %70 = getelementptr inbounds i32, i32* %7, i64 %59
  %71 = load i32, i32* %70, align 4, !tbaa !15
  %72 = icmp slt i32 %71, %1
  br i1 %72, label %78, label %73

73:                                               ; preds = %69
  %74 = trunc i64 %57 to i32
  %75 = add nsw i32 %58, 1
  %76 = sext i32 %58 to i64
  %77 = getelementptr inbounds i32, i32* %2, i64 %76
  store i32 %74, i32* %77, align 4, !tbaa !15
  br label %78

78:                                               ; preds = %69, %73, %56
  %79 = phi i32 [ %58, %56 ], [ %75, %73 ], [ %58, %69 ]
  %80 = add nuw nsw i64 %57, 1
  %81 = icmp eq i64 %80, %13
  br i1 %81, label %97, label %56, !llvm.loop !19

82:                                               ; preds = %51, %21
  %83 = phi i32 [ undef, %21 ], [ %52, %51 ]
  %84 = phi i64 [ 0, %21 ], [ %53, %51 ]
  %85 = phi i32 [ 0, %21 ], [ %52, %51 ]
  %86 = icmp eq i64 %22, 0
  br i1 %86, label %97, label %87

87:                                               ; preds = %82
  %88 = add nsw i64 %17, %84
  %89 = getelementptr inbounds i32, i32* %7, i64 %88
  %90 = load i32, i32* %89, align 4, !tbaa !15
  %91 = icmp slt i32 %90, %1
  br i1 %91, label %97, label %92

92:                                               ; preds = %87
  %93 = trunc i64 %84 to i32
  %94 = add nsw i32 %85, 1
  %95 = sext i32 %85 to i64
  %96 = getelementptr inbounds i32, i32* %2, i64 %95
  store i32 %93, i32* %96, align 4, !tbaa !15
  br label %97

97:                                               ; preds = %78, %82, %92, %87, %11, %3, %5
  %98 = phi i32 [ -1, %5 ], [ -1, %3 ], [ 0, %11 ], [ %83, %82 ], [ %94, %92 ], [ %85, %87 ], [ %79, %78 ]
  ret i32 %98
}

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local i32 @filter_lt_date32_on_sel(i32* noundef readonly %0, i32 noundef %1, %struct.SimpleColumnView* noundef readonly %2, i32 noundef %3, i32* noundef writeonly %4) local_unnamed_addr #0 {
  %6 = icmp ne i32* %0, null
  %7 = icmp ne %struct.SimpleColumnView* %2, null
  %8 = and i1 %6, %7
  br i1 %8, label %9, label %108

9:                                                ; preds = %5
  %10 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %2, i64 0, i32 0
  %11 = load i32*, i32** %10, align 8, !tbaa !5
  %12 = icmp eq i32* %11, null
  %13 = icmp eq i32* %4, null
  %14 = or i1 %13, %12
  %15 = icmp slt i32 %1, 1
  %16 = or i1 %15, %14
  br i1 %16, label %108, label %17

17:                                               ; preds = %9
  %18 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %2, i64 0, i32 3
  %19 = load i64, i64* %18, align 8, !tbaa !13
  %20 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %2, i64 0, i32 1
  %21 = load i8*, i8** %20, align 8, !tbaa !14
  %22 = icmp eq i8* %21, null
  %23 = zext i32 %1 to i64
  br i1 %22, label %24, label %63

24:                                               ; preds = %17
  %25 = and i64 %23, 1
  %26 = icmp eq i32 %1, 1
  br i1 %26, label %91, label %27

27:                                               ; preds = %24
  %28 = and i64 %23, 4294967294
  br label %29

29:                                               ; preds = %58, %27
  %30 = phi i64 [ 0, %27 ], [ %60, %58 ]
  %31 = phi i32 [ 0, %27 ], [ %59, %58 ]
  %32 = phi i64 [ 0, %27 ], [ %61, %58 ]
  %33 = getelementptr inbounds i32, i32* %0, i64 %30
  %34 = load i32, i32* %33, align 4, !tbaa !15
  %35 = zext i32 %34 to i64
  %36 = add nsw i64 %19, %35
  %37 = getelementptr inbounds i32, i32* %11, i64 %36
  %38 = load i32, i32* %37, align 4, !tbaa !15
  %39 = icmp slt i32 %38, %3
  br i1 %39, label %40, label %44

40:                                               ; preds = %29
  %41 = add nsw i32 %31, 1
  %42 = sext i32 %31 to i64
  %43 = getelementptr inbounds i32, i32* %4, i64 %42
  store i32 %34, i32* %43, align 4, !tbaa !15
  br label %44

44:                                               ; preds = %40, %29
  %45 = phi i32 [ %41, %40 ], [ %31, %29 ]
  %46 = or i64 %30, 1
  %47 = getelementptr inbounds i32, i32* %0, i64 %46
  %48 = load i32, i32* %47, align 4, !tbaa !15
  %49 = zext i32 %48 to i64
  %50 = add nsw i64 %19, %49
  %51 = getelementptr inbounds i32, i32* %11, i64 %50
  %52 = load i32, i32* %51, align 4, !tbaa !15
  %53 = icmp slt i32 %52, %3
  br i1 %53, label %54, label %58

54:                                               ; preds = %44
  %55 = add nsw i32 %45, 1
  %56 = sext i32 %45 to i64
  %57 = getelementptr inbounds i32, i32* %4, i64 %56
  store i32 %48, i32* %57, align 4, !tbaa !15
  br label %58

58:                                               ; preds = %54, %44
  %59 = phi i32 [ %55, %54 ], [ %45, %44 ]
  %60 = add nuw nsw i64 %30, 2
  %61 = add i64 %32, 2
  %62 = icmp eq i64 %61, %28
  br i1 %62, label %91, label %29, !llvm.loop !20

63:                                               ; preds = %17, %87
  %64 = phi i64 [ %89, %87 ], [ 0, %17 ]
  %65 = phi i32 [ %88, %87 ], [ 0, %17 ]
  %66 = getelementptr inbounds i32, i32* %0, i64 %64
  %67 = load i32, i32* %66, align 4, !tbaa !15
  %68 = zext i32 %67 to i64
  %69 = add nsw i64 %19, %68
  %70 = sdiv i64 %69, 8
  %71 = srem i64 %69, 8
  %72 = getelementptr inbounds i8, i8* %21, i64 %70
  %73 = load i8, i8* %72, align 1, !tbaa !18
  %74 = zext i8 %73 to i32
  %75 = trunc i64 %71 to i32
  %76 = shl nuw nsw i32 1, %75
  %77 = and i32 %76, %74
  %78 = icmp eq i32 %77, 0
  br i1 %78, label %87, label %79

79:                                               ; preds = %63
  %80 = getelementptr inbounds i32, i32* %11, i64 %69
  %81 = load i32, i32* %80, align 4, !tbaa !15
  %82 = icmp slt i32 %81, %3
  br i1 %82, label %83, label %87

83:                                               ; preds = %79
  %84 = add nsw i32 %65, 1
  %85 = sext i32 %65 to i64
  %86 = getelementptr inbounds i32, i32* %4, i64 %85
  store i32 %67, i32* %86, align 4, !tbaa !15
  br label %87

87:                                               ; preds = %79, %83, %63
  %88 = phi i32 [ %65, %63 ], [ %84, %83 ], [ %65, %79 ]
  %89 = add nuw nsw i64 %64, 1
  %90 = icmp eq i64 %89, %23
  br i1 %90, label %108, label %63, !llvm.loop !20

91:                                               ; preds = %58, %24
  %92 = phi i32 [ undef, %24 ], [ %59, %58 ]
  %93 = phi i64 [ 0, %24 ], [ %60, %58 ]
  %94 = phi i32 [ 0, %24 ], [ %59, %58 ]
  %95 = icmp eq i64 %25, 0
  br i1 %95, label %108, label %96

96:                                               ; preds = %91
  %97 = getelementptr inbounds i32, i32* %0, i64 %93
  %98 = load i32, i32* %97, align 4, !tbaa !15
  %99 = zext i32 %98 to i64
  %100 = add nsw i64 %19, %99
  %101 = getelementptr inbounds i32, i32* %11, i64 %100
  %102 = load i32, i32* %101, align 4, !tbaa !15
  %103 = icmp slt i32 %102, %3
  br i1 %103, label %104, label %108

104:                                              ; preds = %96
  %105 = add nsw i32 %94, 1
  %106 = sext i32 %94 to i64
  %107 = getelementptr inbounds i32, i32* %4, i64 %106
  store i32 %98, i32* %107, align 4, !tbaa !15
  br label %108

108:                                              ; preds = %87, %91, %104, %96, %5, %9
  %109 = phi i32 [ -1, %9 ], [ -1, %5 ], [ %92, %91 ], [ %105, %104 ], [ %94, %96 ], [ %88, %87 ]
  ret i32 %109
}

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local i32 @filter_between_i64_on_sel(i32* noundef readonly %0, i32 noundef %1, %struct.SimpleColumnView* noundef readonly %2, i64 noundef %3, i64 noundef %4, i32* noundef writeonly %5) local_unnamed_addr #0 {
  %7 = icmp ne i32* %0, null
  %8 = icmp ne %struct.SimpleColumnView* %2, null
  %9 = and i1 %7, %8
  br i1 %9, label %10, label %118

10:                                               ; preds = %6
  %11 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %2, i64 0, i32 0
  %12 = load i32*, i32** %11, align 8, !tbaa !5
  %13 = icmp eq i32* %12, null
  %14 = icmp eq i32* %5, null
  %15 = or i1 %14, %13
  %16 = icmp slt i32 %1, 1
  %17 = or i1 %16, %15
  br i1 %17, label %118, label %18

18:                                               ; preds = %10
  %19 = bitcast i32* %12 to i64*
  %20 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %2, i64 0, i32 3
  %21 = load i64, i64* %20, align 8, !tbaa !13
  %22 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %2, i64 0, i32 1
  %23 = load i8*, i8** %22, align 8, !tbaa !14
  %24 = icmp eq i8* %23, null
  %25 = zext i32 %1 to i64
  br i1 %24, label %26, label %69

26:                                               ; preds = %18
  %27 = and i64 %25, 1
  %28 = icmp eq i32 %1, 1
  br i1 %28, label %99, label %29

29:                                               ; preds = %26
  %30 = and i64 %25, 4294967294
  br label %31

31:                                               ; preds = %64, %29
  %32 = phi i64 [ 0, %29 ], [ %66, %64 ]
  %33 = phi i32 [ 0, %29 ], [ %65, %64 ]
  %34 = phi i64 [ 0, %29 ], [ %67, %64 ]
  %35 = getelementptr inbounds i32, i32* %0, i64 %32
  %36 = load i32, i32* %35, align 4, !tbaa !15
  %37 = zext i32 %36 to i64
  %38 = add nsw i64 %21, %37
  %39 = getelementptr inbounds i64, i64* %19, i64 %38
  %40 = load i64, i64* %39, align 8, !tbaa !21
  %41 = icmp slt i64 %40, %3
  %42 = icmp sgt i64 %40, %4
  %43 = or i1 %41, %42
  br i1 %43, label %48, label %44

44:                                               ; preds = %31
  %45 = add nsw i32 %33, 1
  %46 = sext i32 %33 to i64
  %47 = getelementptr inbounds i32, i32* %5, i64 %46
  store i32 %36, i32* %47, align 4, !tbaa !15
  br label %48

48:                                               ; preds = %44, %31
  %49 = phi i32 [ %45, %44 ], [ %33, %31 ]
  %50 = or i64 %32, 1
  %51 = getelementptr inbounds i32, i32* %0, i64 %50
  %52 = load i32, i32* %51, align 4, !tbaa !15
  %53 = zext i32 %52 to i64
  %54 = add nsw i64 %21, %53
  %55 = getelementptr inbounds i64, i64* %19, i64 %54
  %56 = load i64, i64* %55, align 8, !tbaa !21
  %57 = icmp slt i64 %56, %3
  %58 = icmp sgt i64 %56, %4
  %59 = or i1 %57, %58
  br i1 %59, label %64, label %60

60:                                               ; preds = %48
  %61 = add nsw i32 %49, 1
  %62 = sext i32 %49 to i64
  %63 = getelementptr inbounds i32, i32* %5, i64 %62
  store i32 %52, i32* %63, align 4, !tbaa !15
  br label %64

64:                                               ; preds = %60, %48
  %65 = phi i32 [ %61, %60 ], [ %49, %48 ]
  %66 = add nuw nsw i64 %32, 2
  %67 = add i64 %34, 2
  %68 = icmp eq i64 %67, %30
  br i1 %68, label %99, label %31, !llvm.loop !22

69:                                               ; preds = %18, %95
  %70 = phi i64 [ %97, %95 ], [ 0, %18 ]
  %71 = phi i32 [ %96, %95 ], [ 0, %18 ]
  %72 = getelementptr inbounds i32, i32* %0, i64 %70
  %73 = load i32, i32* %72, align 4, !tbaa !15
  %74 = zext i32 %73 to i64
  %75 = add nsw i64 %21, %74
  %76 = sdiv i64 %75, 8
  %77 = srem i64 %75, 8
  %78 = getelementptr inbounds i8, i8* %23, i64 %76
  %79 = load i8, i8* %78, align 1, !tbaa !18
  %80 = zext i8 %79 to i32
  %81 = trunc i64 %77 to i32
  %82 = shl nuw nsw i32 1, %81
  %83 = and i32 %82, %80
  %84 = icmp eq i32 %83, 0
  br i1 %84, label %95, label %85

85:                                               ; preds = %69
  %86 = getelementptr inbounds i64, i64* %19, i64 %75
  %87 = load i64, i64* %86, align 8, !tbaa !21
  %88 = icmp slt i64 %87, %3
  %89 = icmp sgt i64 %87, %4
  %90 = or i1 %88, %89
  br i1 %90, label %95, label %91

91:                                               ; preds = %85
  %92 = add nsw i32 %71, 1
  %93 = sext i32 %71 to i64
  %94 = getelementptr inbounds i32, i32* %5, i64 %93
  store i32 %73, i32* %94, align 4, !tbaa !15
  br label %95

95:                                               ; preds = %85, %91, %69
  %96 = phi i32 [ %71, %69 ], [ %92, %91 ], [ %71, %85 ]
  %97 = add nuw nsw i64 %70, 1
  %98 = icmp eq i64 %97, %25
  br i1 %98, label %118, label %69, !llvm.loop !22

99:                                               ; preds = %64, %26
  %100 = phi i32 [ undef, %26 ], [ %65, %64 ]
  %101 = phi i64 [ 0, %26 ], [ %66, %64 ]
  %102 = phi i32 [ 0, %26 ], [ %65, %64 ]
  %103 = icmp eq i64 %27, 0
  br i1 %103, label %118, label %104

104:                                              ; preds = %99
  %105 = getelementptr inbounds i32, i32* %0, i64 %101
  %106 = load i32, i32* %105, align 4, !tbaa !15
  %107 = zext i32 %106 to i64
  %108 = add nsw i64 %21, %107
  %109 = getelementptr inbounds i64, i64* %19, i64 %108
  %110 = load i64, i64* %109, align 8, !tbaa !21
  %111 = icmp slt i64 %110, %3
  %112 = icmp sgt i64 %110, %4
  %113 = or i1 %111, %112
  br i1 %113, label %118, label %114

114:                                              ; preds = %104
  %115 = add nsw i32 %102, 1
  %116 = sext i32 %102 to i64
  %117 = getelementptr inbounds i32, i32* %5, i64 %116
  store i32 %106, i32* %117, align 4, !tbaa !15
  br label %118

118:                                              ; preds = %95, %99, %114, %104, %6, %10
  %119 = phi i32 [ -1, %10 ], [ -1, %6 ], [ %100, %99 ], [ %115, %114 ], [ %102, %104 ], [ %96, %95 ]
  ret i32 %119
}

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local i32 @filter_lt_i64_on_sel(i32* noundef readonly %0, i32 noundef %1, %struct.SimpleColumnView* noundef readonly %2, i64 noundef %3, i32* noundef writeonly %4) local_unnamed_addr #0 {
  %6 = icmp ne i32* %0, null
  %7 = icmp ne %struct.SimpleColumnView* %2, null
  %8 = and i1 %6, %7
  br i1 %8, label %9, label %109

9:                                                ; preds = %5
  %10 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %2, i64 0, i32 0
  %11 = load i32*, i32** %10, align 8, !tbaa !5
  %12 = icmp eq i32* %11, null
  %13 = icmp eq i32* %4, null
  %14 = or i1 %13, %12
  %15 = icmp slt i32 %1, 1
  %16 = or i1 %15, %14
  br i1 %16, label %109, label %17

17:                                               ; preds = %9
  %18 = bitcast i32* %11 to i64*
  %19 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %2, i64 0, i32 3
  %20 = load i64, i64* %19, align 8, !tbaa !13
  %21 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %2, i64 0, i32 1
  %22 = load i8*, i8** %21, align 8, !tbaa !14
  %23 = icmp eq i8* %22, null
  %24 = zext i32 %1 to i64
  br i1 %23, label %25, label %64

25:                                               ; preds = %17
  %26 = and i64 %24, 1
  %27 = icmp eq i32 %1, 1
  br i1 %27, label %92, label %28

28:                                               ; preds = %25
  %29 = and i64 %24, 4294967294
  br label %30

30:                                               ; preds = %59, %28
  %31 = phi i64 [ 0, %28 ], [ %61, %59 ]
  %32 = phi i32 [ 0, %28 ], [ %60, %59 ]
  %33 = phi i64 [ 0, %28 ], [ %62, %59 ]
  %34 = getelementptr inbounds i32, i32* %0, i64 %31
  %35 = load i32, i32* %34, align 4, !tbaa !15
  %36 = zext i32 %35 to i64
  %37 = add nsw i64 %20, %36
  %38 = getelementptr inbounds i64, i64* %18, i64 %37
  %39 = load i64, i64* %38, align 8, !tbaa !21
  %40 = icmp slt i64 %39, %3
  br i1 %40, label %41, label %45

41:                                               ; preds = %30
  %42 = add nsw i32 %32, 1
  %43 = sext i32 %32 to i64
  %44 = getelementptr inbounds i32, i32* %4, i64 %43
  store i32 %35, i32* %44, align 4, !tbaa !15
  br label %45

45:                                               ; preds = %41, %30
  %46 = phi i32 [ %42, %41 ], [ %32, %30 ]
  %47 = or i64 %31, 1
  %48 = getelementptr inbounds i32, i32* %0, i64 %47
  %49 = load i32, i32* %48, align 4, !tbaa !15
  %50 = zext i32 %49 to i64
  %51 = add nsw i64 %20, %50
  %52 = getelementptr inbounds i64, i64* %18, i64 %51
  %53 = load i64, i64* %52, align 8, !tbaa !21
  %54 = icmp slt i64 %53, %3
  br i1 %54, label %55, label %59

55:                                               ; preds = %45
  %56 = add nsw i32 %46, 1
  %57 = sext i32 %46 to i64
  %58 = getelementptr inbounds i32, i32* %4, i64 %57
  store i32 %49, i32* %58, align 4, !tbaa !15
  br label %59

59:                                               ; preds = %55, %45
  %60 = phi i32 [ %56, %55 ], [ %46, %45 ]
  %61 = add nuw nsw i64 %31, 2
  %62 = add i64 %33, 2
  %63 = icmp eq i64 %62, %29
  br i1 %63, label %92, label %30, !llvm.loop !23

64:                                               ; preds = %17, %88
  %65 = phi i64 [ %90, %88 ], [ 0, %17 ]
  %66 = phi i32 [ %89, %88 ], [ 0, %17 ]
  %67 = getelementptr inbounds i32, i32* %0, i64 %65
  %68 = load i32, i32* %67, align 4, !tbaa !15
  %69 = zext i32 %68 to i64
  %70 = add nsw i64 %20, %69
  %71 = sdiv i64 %70, 8
  %72 = srem i64 %70, 8
  %73 = getelementptr inbounds i8, i8* %22, i64 %71
  %74 = load i8, i8* %73, align 1, !tbaa !18
  %75 = zext i8 %74 to i32
  %76 = trunc i64 %72 to i32
  %77 = shl nuw nsw i32 1, %76
  %78 = and i32 %77, %75
  %79 = icmp eq i32 %78, 0
  br i1 %79, label %88, label %80

80:                                               ; preds = %64
  %81 = getelementptr inbounds i64, i64* %18, i64 %70
  %82 = load i64, i64* %81, align 8, !tbaa !21
  %83 = icmp slt i64 %82, %3
  br i1 %83, label %84, label %88

84:                                               ; preds = %80
  %85 = add nsw i32 %66, 1
  %86 = sext i32 %66 to i64
  %87 = getelementptr inbounds i32, i32* %4, i64 %86
  store i32 %68, i32* %87, align 4, !tbaa !15
  br label %88

88:                                               ; preds = %80, %84, %64
  %89 = phi i32 [ %66, %64 ], [ %85, %84 ], [ %66, %80 ]
  %90 = add nuw nsw i64 %65, 1
  %91 = icmp eq i64 %90, %24
  br i1 %91, label %109, label %64, !llvm.loop !23

92:                                               ; preds = %59, %25
  %93 = phi i32 [ undef, %25 ], [ %60, %59 ]
  %94 = phi i64 [ 0, %25 ], [ %61, %59 ]
  %95 = phi i32 [ 0, %25 ], [ %60, %59 ]
  %96 = icmp eq i64 %26, 0
  br i1 %96, label %109, label %97

97:                                               ; preds = %92
  %98 = getelementptr inbounds i32, i32* %0, i64 %94
  %99 = load i32, i32* %98, align 4, !tbaa !15
  %100 = zext i32 %99 to i64
  %101 = add nsw i64 %20, %100
  %102 = getelementptr inbounds i64, i64* %18, i64 %101
  %103 = load i64, i64* %102, align 8, !tbaa !21
  %104 = icmp slt i64 %103, %3
  br i1 %104, label %105, label %109

105:                                              ; preds = %97
  %106 = add nsw i32 %95, 1
  %107 = sext i32 %95 to i64
  %108 = getelementptr inbounds i32, i32* %4, i64 %107
  store i32 %99, i32* %108, align 4, !tbaa !15
  br label %109

109:                                              ; preds = %88, %92, %105, %97, %5, %9
  %110 = phi i32 [ -1, %9 ], [ -1, %5 ], [ %93, %92 ], [ %106, %105 ], [ %95, %97 ], [ %89, %88 ]
  ret i32 %110
}

attributes #0 = { nofree norecurse nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
!5 = !{!6, !7, i64 0}
!6 = !{!"", !7, i64 0, !7, i64 8, !10, i64 16, !10, i64 24, !11, i64 32}
!7 = !{!"any pointer", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = !{!"long", !8, i64 0}
!11 = !{!"int", !8, i64 0}
!12 = !{!6, !10, i64 16}
!13 = !{!6, !10, i64 24}
!14 = !{!6, !7, i64 8}
!15 = !{!11, !11, i64 0}
!16 = distinct !{!16, !17}
!17 = !{!"llvm.loop.mustprogress"}
!18 = !{!8, !8, i64 0}
!19 = distinct !{!19, !17}
!20 = distinct !{!20, !17}
!21 = !{!10, !10, i64 0}
!22 = distinct !{!22, !17}
!23 = distinct !{!23, !17}
