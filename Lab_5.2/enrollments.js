
// Частина 1: Базові агрегаційні операції
//1. Відфільтруйте замовлення за останні 3 місяці
const threeMonthsAgo = new Date();
threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);

db.Enrollments.aggregate([
  {
    $match: {
      semester: { $gte: threeMonthsAgo }
    }
  }
]);
//2.Групування замовлень за місяцем
db.Enrollments.aggregate([
  {
    $group: {
      _id: { month: { $month: "$semester" }, year: { $year: "$semester" } },
      totalEnrollments: { $sum: 1 }
    }
  }
]);
//3 . Сортування за сумою замовлення
db.Enrollments.aggregate([
  {
    $project: {
      enrNO: 1,
      studentEmail: 1,
      coursesCount: { $size: "$items" }
    }
  },
  {
    $sort: { coursesCount: -1 } // -1 для спадання
  }
]);
//Частина 2: Робота з масивами
// Розгорніть масив items у замовленнях
db.Enrollments.aggregate([
  { $unwind: "$items" }
]);
//Підрахуйте кількість проданих одиниць товарів (кількість записів на кожен курс)
db.Enrollments.aggregate([
  { $unwind: "$items" },
  {
    $group: {
      _id: "$items.course",
      totalEnrolled: { $sum: 1 }
    }
  },
  { $sort: { totalEnrolled: -1 } }
]);
//Частина 3: З’єднання колекцій ($lookup)
//Отримання інформації про клієнтів (студентів) у замовленнях
db.Enrollments.aggregate([
  {
    $lookup: {
      from: "Students",
      localField: "studentEmail",
      foreignField: "email",
      as: "studentInfo"
    }
  }
]);
//Визначте найбільш активних клієнтів (студентів з найбільшою кількістю записів)
db.Enrollments.aggregate([
  {
    $group: {
      _id: "$studentEmail",
      enrollmentsCount: { $sum: 1 }
    }
  },
  { $sort: { enrollmentsCount: -1 } },
  { $limit: 3 }
]);
//Частина 4: Оптимізація запитів
// Перевірте продуктивність запиту
db.runCommand({
  explain: {
    aggregate: "Enrollments",
    pipeline: [
      { $match: { status: "Enrolled" } },
      { $lookup: { from: "Students", localField: "studentEmail", foreignField: "email", as: "student" } }
    ],
    cursor: {}
  },
  verbosity: "executionStats"
});
// Оптимізуйте агрегаційний запит
db.Enrollments.aggregate([
  // 1. Фільтрація (використовує індекс)
  { $match: { status: "Enrolled" } }, 
  // 2. З'єднання (виконується лише для відфільтрованих документів)
  {
    $lookup: {
      from: "Students",
      localField: "studentEmail",
      foreignField: "email",
      as: "studentInfo"
    }
  }
]);

// Додаткові завдання 
// Визначте категорії товарів (кафедри) із найбільшою кількістю продажів (записів)
db.Enrollments.aggregate([
  { $unwind: "$items" },
  {
    $lookup: {
      from: "Courses",
      localField: "items.course",
      foreignField: "title",
      as: "courseDetails"
    }
  },
  { $unwind: "$courseDetails" },
  {
    $group: {
      _id: "$courseDetails.department",
      totalEnrolled: { $sum: 1 }
    }
  },
  { $sort: { totalEnrolled: -1 } }
]);
// Розрахуйте середню ціну товарів (кількість кредитів) у кожній категорії (кафедрі)
db.Courses.aggregate([
  {
    $addFields: {
      numericCredits: { $toInt: "$credits" }
    }
  },
  {
    $group: {
      _id: "$department",
      avgCredits: { $avg: "$numericCredits" }
    }
  }
]);
// Знайдіть користувачів (студентів), які зробили більше одного замовлення (запису)
db.Enrollments.aggregate([
  {
    $group: {
      _id: "$studentEmail",
      totalOrders: { $sum: 1 }
    }
  },
  {
    $match: {
      totalOrders: { $gt: 1 }
    }
  }
]);
//$match — для фільтрації документів за певними критеріями (аналог WHERE у SQL).
//$group — для групування документів за певним ключем та виконання агрегатних функцій (підрахунок кількості $sum, знаходження середнього $avg).
//$sort — для сортування результуючих документів.
//$unwind — для «розгортання» масивів. Він створює окремий документ для кожного елемента масиву (наприклад, для кожного курсу в масиві items).
//$lookup — для з'єднання (join) даних з інших колекцій.
//$project — для формування вихідного документа (включення/виключення полів або створення нових обчислюваних полів, як-от розмір масиву через $size).
//$limit — для обмеження кількості повернутих документів (наприклад, топ-3 найактивніших студентів).