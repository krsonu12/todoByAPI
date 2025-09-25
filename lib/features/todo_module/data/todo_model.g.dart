part of 'todo_model.dart';

_$TodoModelImpl _$$TodoModelImplFromJson(Map<String, dynamic> json) =>
    _$TodoModelImpl(
      userId: (json['userId'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );

Map<String, dynamic> _$$TodoModelImplToJson(_$TodoModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'id': instance.id,
      'title': instance.title,
      'completed': instance.completed,
    };
