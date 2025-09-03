; ModuleID = 'filter_kernels.c'
source_filename = "filter_kernels.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.SimpleColumnView = type { ptr, ptr, i64, i64, i32 }

; Function Attrs: nofree norecurse nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local i32 @filter_le_date32(ptr noundef readonly %0, i32 noundef %1, ptr noundef writeonly %2) local_unnamed_addr #0 {
  %4 = icmp eq ptr %0, null
  br i1 %4, label %48, label %5

5:                                                ; preds = %3
  %6 = load ptr, ptr %0, align 8, !tbaa !5
  %7 = icmp ne ptr %6, null
  %8 = icmp ne ptr %2, null
  %9 = and i1 %8, %7
  br i1 %9, label %10, label %48

10:                                               ; preds = %5
  %11 = getelementptr inbounds %struct.SimpleColumnView, ptr %0, i64 0, i32 2
  %12 = load i64, ptr %11, align 8, !tbaa !12
  %13 = icmp sgt i64 %12, 0
  br i1 %13, label %14, label %48

14:                                               ; preds = %10
  %15 = getelementptr inbounds %struct.SimpleColumnView, ptr %0, i64 0, i32 3
  %16 = load i64, ptr %15, align 8, !tbaa !13
  %17 = getelementptr inbounds %struct.SimpleColumnView, ptr %0, i64 0, i32 1
  %18 = load ptr, ptr %17, align 8, !tbaa !14
  %19 = icmp eq ptr %18, null
  %20 = getelementptr i32, ptr %6, i64 %16
  br label %21

21:                                               ; preds = %14, %44
  %22 = phi i64 [ 0, %14 ], [ %46, %44 ]
  %23 = phi i32 [ 0, %14 ], [ %45, %44 ]
  br i1 %19, label %35, label %24

24:                                               ; preds = %21
  %25 = add nsw i64 %16, %22
  %26 = sdiv i64 %25, 8
  %27 = srem i64 %25, 8
  %28 = getelementptr inbounds i8, ptr %18, i64 %26
  %29 = load i8, ptr %28, align 1, !tbaa !15
  %30 = zext i8 %29 to i32
  %31 = trunc i64 %27 to i32
  %32 = shl nuw nsw i32 1, %31
  %33 = and i32 %32, %30
  %34 = icmp eq i32 %33, 0
  br i1 %34, label %44, label %35

35:                                               ; preds = %21, %24
  %36 = getelementptr i32, ptr %20, i64 %22
  %37 = load i32, ptr %36, align 4, !tbaa !16
  %38 = icmp sgt i32 %37, %1
  br i1 %38, label %44, label %39

39:                                               ; preds = %35
  %40 = trunc i64 %22 to i32
  %41 = add nsw i32 %23, 1
  %42 = sext i32 %23 to i64
  %43 = getelementptr inbounds i32, ptr %2, i64 %42
  store i32 %40, ptr %43, align 4, !tbaa !16
  br label %44

44:                                               ; preds = %35, %39, %24
  %45 = phi i32 [ %23, %24 ], [ %41, %39 ], [ %23, %35 ]
  %46 = add nuw nsw i64 %22, 1
  %47 = icmp eq i64 %46, %12
  br i1 %47, label %48, label %21, !llvm.loop !17

48:                                               ; preds = %44, %10, %3, %5
  %49 = phi i32 [ -1, %5 ], [ -1, %3 ], [ 0, %10 ], [ %45, %44 ]
  ret i32 %49
}

; Function Attrs: nofree norecurse nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local i32 @filter_ge_date32(ptr noundef readonly %0, i32 noundef %1, ptr noundef writeonly %2) local_unnamed_addr #0 {
  %4 = icmp eq ptr %0, null
  br i1 %4, label %48, label %5

5:                                                ; preds = %3
  %6 = load ptr, ptr %0, align 8, !tbaa !5
  %7 = icmp ne ptr %6, null
  %8 = icmp ne ptr %2, null
  %9 = and i1 %8, %7
  br i1 %9, label %10, label %48

10:                                               ; preds = %5
  %11 = getelementptr inbounds %struct.SimpleColumnView, ptr %0, i64 0, i32 2
  %12 = load i64, ptr %11, align 8, !tbaa !12
  %13 = icmp sgt i64 %12, 0
  br i1 %13, label %14, label %48

14:                                               ; preds = %10
  %15 = getelementptr inbounds %struct.SimpleColumnView, ptr %0, i64 0, i32 3
  %16 = load i64, ptr %15, align 8, !tbaa !13
  %17 = getelementptr inbounds %struct.SimpleColumnView, ptr %0, i64 0, i32 1
  %18 = load ptr, ptr %17, align 8, !tbaa !14
  %19 = icmp eq ptr %18, null
  %20 = getelementptr i32, ptr %6, i64 %16
  br label %21

21:                                               ; preds = %14, %44
  %22 = phi i64 [ 0, %14 ], [ %46, %44 ]
  %23 = phi i32 [ 0, %14 ], [ %45, %44 ]
  br i1 %19, label %35, label %24

24:                                               ; preds = %21
  %25 = add nsw i64 %16, %22
  %26 = sdiv i64 %25, 8
  %27 = srem i64 %25, 8
  %28 = getelementptr inbounds i8, ptr %18, i64 %26
  %29 = load i8, ptr %28, align 1, !tbaa !15
  %30 = zext i8 %29 to i32
  %31 = trunc i64 %27 to i32
  %32 = shl nuw nsw i32 1, %31
  %33 = and i32 %32, %30
  %34 = icmp eq i32 %33, 0
  br i1 %34, label %44, label %35

35:                                               ; preds = %21, %24
  %36 = getelementptr i32, ptr %20, i64 %22
  %37 = load i32, ptr %36, align 4, !tbaa !16
  %38 = icmp slt i32 %37, %1
  br i1 %38, label %44, label %39

39:                                               ; preds = %35
  %40 = trunc i64 %22 to i32
  %41 = add nsw i32 %23, 1
  %42 = sext i32 %23 to i64
  %43 = getelementptr inbounds i32, ptr %2, i64 %42
  store i32 %40, ptr %43, align 4, !tbaa !16
  br label %44

44:                                               ; preds = %35, %39, %24
  %45 = phi i32 [ %23, %24 ], [ %41, %39 ], [ %23, %35 ]
  %46 = add nuw nsw i64 %22, 1
  %47 = icmp eq i64 %46, %12
  br i1 %47, label %48, label %21, !llvm.loop !19

48:                                               ; preds = %44, %10, %3, %5
  %49 = phi i32 [ -1, %5 ], [ -1, %3 ], [ 0, %10 ], [ %45, %44 ]
  ret i32 %49
}

; Function Attrs: nofree norecurse nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local i32 @filter_lt_date32_on_sel(ptr noundef readonly %0, i32 noundef %1, ptr noundef readonly %2, i32 noundef %3, ptr noundef writeonly %4) local_unnamed_addr #0 {
  %6 = icmp ne ptr %0, null
  %7 = icmp ne ptr %2, null
  %8 = and i1 %6, %7
  br i1 %8, label %9, label %53

9:                                                ; preds = %5
  %10 = load ptr, ptr %2, align 8, !tbaa !5
  %11 = icmp eq ptr %10, null
  %12 = icmp eq ptr %4, null
  %13 = or i1 %12, %11
  %14 = icmp slt i32 %1, 1
  %15 = or i1 %14, %13
  br i1 %15, label %53, label %16

16:                                               ; preds = %9
  %17 = getelementptr inbounds %struct.SimpleColumnView, ptr %2, i64 0, i32 3
  %18 = load i64, ptr %17, align 8, !tbaa !13
  %19 = getelementptr inbounds %struct.SimpleColumnView, ptr %2, i64 0, i32 1
  %20 = load ptr, ptr %19, align 8, !tbaa !14
  %21 = icmp eq ptr %20, null
  %22 = getelementptr i32, ptr %10, i64 %18
  %23 = zext nneg i32 %1 to i64
  br label %24

24:                                               ; preds = %16, %49
  %25 = phi i64 [ 0, %16 ], [ %51, %49 ]
  %26 = phi i32 [ 0, %16 ], [ %50, %49 ]
  %27 = getelementptr inbounds i32, ptr %0, i64 %25
  %28 = load i32, ptr %27, align 4, !tbaa !16
  %29 = zext i32 %28 to i64
  br i1 %21, label %41, label %30

30:                                               ; preds = %24
  %31 = add nsw i64 %18, %29
  %32 = sdiv i64 %31, 8
  %33 = srem i64 %31, 8
  %34 = getelementptr inbounds i8, ptr %20, i64 %32
  %35 = load i8, ptr %34, align 1, !tbaa !15
  %36 = zext i8 %35 to i32
  %37 = trunc i64 %33 to i32
  %38 = shl nuw nsw i32 1, %37
  %39 = and i32 %38, %36
  %40 = icmp eq i32 %39, 0
  br i1 %40, label %49, label %41

41:                                               ; preds = %24, %30
  %42 = getelementptr i32, ptr %22, i64 %29
  %43 = load i32, ptr %42, align 4, !tbaa !16
  %44 = icmp slt i32 %43, %3
  br i1 %44, label %45, label %49

45:                                               ; preds = %41
  %46 = add nsw i32 %26, 1
  %47 = sext i32 %26 to i64
  %48 = getelementptr inbounds i32, ptr %4, i64 %47
  store i32 %28, ptr %48, align 4, !tbaa !16
  br label %49

49:                                               ; preds = %41, %45, %30
  %50 = phi i32 [ %26, %30 ], [ %46, %45 ], [ %26, %41 ]
  %51 = add nuw nsw i64 %25, 1
  %52 = icmp eq i64 %51, %23
  br i1 %52, label %53, label %24, !llvm.loop !20

53:                                               ; preds = %49, %5, %9
  %54 = phi i32 [ -1, %9 ], [ -1, %5 ], [ %50, %49 ]
  ret i32 %54
}

; Function Attrs: nofree norecurse nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local i32 @filter_between_i64_on_sel(ptr noundef readonly %0, i32 noundef %1, ptr noundef readonly %2, i64 noundef %3, i64 noundef %4, ptr noundef writeonly %5) local_unnamed_addr #0 {
  %7 = icmp ne ptr %0, null
  %8 = icmp ne ptr %2, null
  %9 = and i1 %7, %8
  br i1 %9, label %10, label %56

10:                                               ; preds = %6
  %11 = load ptr, ptr %2, align 8, !tbaa !5
  %12 = icmp eq ptr %11, null
  %13 = icmp eq ptr %5, null
  %14 = or i1 %13, %12
  %15 = icmp slt i32 %1, 1
  %16 = or i1 %15, %14
  br i1 %16, label %56, label %17

17:                                               ; preds = %10
  %18 = getelementptr inbounds %struct.SimpleColumnView, ptr %2, i64 0, i32 3
  %19 = load i64, ptr %18, align 8, !tbaa !13
  %20 = getelementptr inbounds %struct.SimpleColumnView, ptr %2, i64 0, i32 1
  %21 = load ptr, ptr %20, align 8, !tbaa !14
  %22 = icmp eq ptr %21, null
  %23 = getelementptr i64, ptr %11, i64 %19
  %24 = zext nneg i32 %1 to i64
  br label %25

25:                                               ; preds = %17, %52
  %26 = phi i64 [ 0, %17 ], [ %54, %52 ]
  %27 = phi i32 [ 0, %17 ], [ %53, %52 ]
  %28 = getelementptr inbounds i32, ptr %0, i64 %26
  %29 = load i32, ptr %28, align 4, !tbaa !16
  %30 = zext i32 %29 to i64
  br i1 %22, label %42, label %31

31:                                               ; preds = %25
  %32 = add nsw i64 %19, %30
  %33 = sdiv i64 %32, 8
  %34 = srem i64 %32, 8
  %35 = getelementptr inbounds i8, ptr %21, i64 %33
  %36 = load i8, ptr %35, align 1, !tbaa !15
  %37 = zext i8 %36 to i32
  %38 = trunc i64 %34 to i32
  %39 = shl nuw nsw i32 1, %38
  %40 = and i32 %39, %37
  %41 = icmp eq i32 %40, 0
  br i1 %41, label %52, label %42

42:                                               ; preds = %25, %31
  %43 = getelementptr i64, ptr %23, i64 %30
  %44 = load i64, ptr %43, align 8, !tbaa !21
  %45 = icmp slt i64 %44, %3
  %46 = icmp sgt i64 %44, %4
  %47 = or i1 %45, %46
  br i1 %47, label %52, label %48

48:                                               ; preds = %42
  %49 = add nsw i32 %27, 1
  %50 = sext i32 %27 to i64
  %51 = getelementptr inbounds i32, ptr %5, i64 %50
  store i32 %29, ptr %51, align 4, !tbaa !16
  br label %52

52:                                               ; preds = %42, %48, %31
  %53 = phi i32 [ %27, %31 ], [ %49, %48 ], [ %27, %42 ]
  %54 = add nuw nsw i64 %26, 1
  %55 = icmp eq i64 %54, %24
  br i1 %55, label %56, label %25, !llvm.loop !22

56:                                               ; preds = %52, %6, %10
  %57 = phi i32 [ -1, %10 ], [ -1, %6 ], [ %53, %52 ]
  ret i32 %57
}

; Function Attrs: nofree norecurse nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local i32 @filter_lt_i64_on_sel(ptr noundef readonly %0, i32 noundef %1, ptr noundef readonly %2, i64 noundef %3, ptr noundef writeonly %4) local_unnamed_addr #0 {
  %6 = icmp ne ptr %0, null
  %7 = icmp ne ptr %2, null
  %8 = and i1 %6, %7
  br i1 %8, label %9, label %53

9:                                                ; preds = %5
  %10 = load ptr, ptr %2, align 8, !tbaa !5
  %11 = icmp eq ptr %10, null
  %12 = icmp eq ptr %4, null
  %13 = or i1 %12, %11
  %14 = icmp slt i32 %1, 1
  %15 = or i1 %14, %13
  br i1 %15, label %53, label %16

16:                                               ; preds = %9
  %17 = getelementptr inbounds %struct.SimpleColumnView, ptr %2, i64 0, i32 3
  %18 = load i64, ptr %17, align 8, !tbaa !13
  %19 = getelementptr inbounds %struct.SimpleColumnView, ptr %2, i64 0, i32 1
  %20 = load ptr, ptr %19, align 8, !tbaa !14
  %21 = icmp eq ptr %20, null
  %22 = getelementptr i64, ptr %10, i64 %18
  %23 = zext nneg i32 %1 to i64
  br label %24

24:                                               ; preds = %16, %49
  %25 = phi i64 [ 0, %16 ], [ %51, %49 ]
  %26 = phi i32 [ 0, %16 ], [ %50, %49 ]
  %27 = getelementptr inbounds i32, ptr %0, i64 %25
  %28 = load i32, ptr %27, align 4, !tbaa !16
  %29 = zext i32 %28 to i64
  br i1 %21, label %41, label %30

30:                                               ; preds = %24
  %31 = add nsw i64 %18, %29
  %32 = sdiv i64 %31, 8
  %33 = srem i64 %31, 8
  %34 = getelementptr inbounds i8, ptr %20, i64 %32
  %35 = load i8, ptr %34, align 1, !tbaa !15
  %36 = zext i8 %35 to i32
  %37 = trunc i64 %33 to i32
  %38 = shl nuw nsw i32 1, %37
  %39 = and i32 %38, %36
  %40 = icmp eq i32 %39, 0
  br i1 %40, label %49, label %41

41:                                               ; preds = %24, %30
  %42 = getelementptr i64, ptr %22, i64 %29
  %43 = load i64, ptr %42, align 8, !tbaa !21
  %44 = icmp slt i64 %43, %3
  br i1 %44, label %45, label %49

45:                                               ; preds = %41
  %46 = add nsw i32 %26, 1
  %47 = sext i32 %26 to i64
  %48 = getelementptr inbounds i32, ptr %4, i64 %47
  store i32 %28, ptr %48, align 4, !tbaa !16
  br label %49

49:                                               ; preds = %41, %45, %30
  %50 = phi i32 [ %26, %30 ], [ %46, %45 ], [ %26, %41 ]
  %51 = add nuw nsw i64 %25, 1
  %52 = icmp eq i64 %51, %23
  br i1 %52, label %53, label %24, !llvm.loop !23

53:                                               ; preds = %49, %5, %9
  %54 = phi i32 [ -1, %9 ], [ -1, %5 ], [ %50, %49 ]
  ret i32 %54
}

attributes #0 = { nofree norecurse nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Homebrew clang version 18.1.8"}
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
!15 = !{!8, !8, i64 0}
!16 = !{!11, !11, i64 0}
!17 = distinct !{!17, !18}
!18 = !{!"llvm.loop.mustprogress"}
!19 = distinct !{!19, !18}
!20 = distinct !{!20, !18}
!21 = !{!10, !10, i64 0}
!22 = distinct !{!22, !18}
!23 = distinct !{!23, !18}
